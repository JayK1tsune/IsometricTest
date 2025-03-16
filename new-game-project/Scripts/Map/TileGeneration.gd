extends TileMapLayer
class_name Blocks
var hud = Hud.new()
var astar = AStarGrid2D.new()
@export var aStarScript : Astar_Script
@export var hold_threshold := 0.2  # Time in seconds to switch from single-click to hold
@export var gridSize_x_ground = 10  # Ground layer width
@export var gridSize_y_ground = 10  # Ground layer height
@export var gridSize_x_level_1 = 10  # Level 1 width
@export var gridSize_y_level_1 = 10  # Level 1 height
@export var gridSize_x_level_2 = 10  # Level 2 width
@export var gridSize_y_level_2 = 10  # Level 2 height
@export var Hazzards : int  # Level 2 height

@onready var ground = $"."
@onready var level_1 = $Level1
@onready var level_2 = $Level2


var is_holding:= false
var left_click_timer:= 0.0
var is_mouse_in_UI: bool:
	get = get_mouse_ui, set = set_mouse_ui

func get_mouse_ui():
	is_mouse_in_UI = hud.is_mouse_in_UI()
	return is_mouse_in_UI
	
func set_mouse_ui(value: bool):
	is_mouse_in_UI = value
	

enum Layer {
	GROUND,
	LEVEL_1,
	LEVEL_2
}

var current_layer = Layer.GROUND
const TILE_WIDTH = 32  # Width of the tile (horizontal dimension)
const TILE_HEIGHT = 16  # Height of the tile (vertical dimension)
const main_source = 0
const hazzard_source = 1

var block_dic = {
	0:Vector2i(0, 0),
	1:Vector2i(1, 0),
	2:Vector2i(2, 0),
	3:Vector2i(3, 0),
	4:Vector2i(4, 0),
}
var hazzard_dic = {
	0:Vector2i(0,0)
}

var layer_map = {}
var  blockId = 0

func _get_block_id() -> Vector2i:
	return block_dic.get(blockId,Vector2i(0,0))
func _get_hazzard_block_id() -> Vector2i:
	return hazzard_dic.get(blockId,Vector2i(1,0))
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	layer_map ={
		Layer.GROUND: ground,
		Layer.LEVEL_1: level_1,
		Layer.LEVEL_2: level_2
	}
	
	astar.size = Vector2i(32,32)
	astar.cell_size = Vector2i(16,16)
	astar.CELL_SHAPE_ISOMETRIC_DOWN
	astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar.update()
	
	

	# Generate the ground layer
	await GenerateLevel(ground, gridSize_x_ground, gridSize_y_ground)
	print_debug("Ground complete")
	
	# Generate level 1
	await GenerateLevel(level_1,gridSize_x_level_1, gridSize_y_level_1)
	print_debug("Level 1 complete")
	
	# Generate level 2
	await GenerateLevel(level_2,gridSize_x_level_2, gridSize_y_level_2)
	print_debug("Level 2 complete")
	
	aStarScript.ShowPath()


func GenerateLevel(level: TileMapLayer, gridSize_x: int, gridSize_y: int):
	var placed_blocks = {}
	var first_block_placed = false
	var layer = level.y_sort_origin 
	var remaning_hazzards = Hazzards
	for y in range(gridSize_y):
		for x in range(gridSize_x):			
			var coords = Vector2i(x, y)

			# Ensure the new coordinates are within grid boundaries
			if not placed_blocks.has(coords) and (first_block_placed == false or HasAdjacentBlock(coords, placed_blocks)):
				level.y_sort_origin = layer
				var selected_block_source
				var selected_block
				if remaning_hazzards > 0 and first_block_placed == true:
					if randf() < 0.25:
						selected_block_source = 1
						selected_block = GrabRandomBlock(selected_block_source)
						astar.set_point_solid(coords,true)
						print("DANGER BLOCK",coords)
						remaning_hazzards -= 1
					else:
						selected_block_source = 0
						selected_block = GrabRandomBlock(selected_block_source)
				else :
					selected_block_source = 0
					selected_block = GrabRandomBlock(selected_block_source)


				level.set_cell(coords, selected_block_source, selected_block)

				placed_blocks[coords] = true
				first_block_placed = true

				# Delay for visual feedback or for other purposes
				const delay := 0.1
				await get_tree().create_timer(delay).timeout

	print_debug("Total blocks placed on level:", level.name, "with count:", placed_blocks.size())


# Get a random block from the available options
func GrabRandomBlock(source: int) -> Vector2i:
	if source == 0:
		return block_dic.values().pick_random()
	else:
		return _get_hazzard_block_id()

	

	

func SetTileColor(coords: Vector2i, layer: Layer, color: Color):
	var tilemap = layer_map[layer]
	var tile_data = tilemap.get_cell_tile_data(coords)
	if tile_data:
		tile_data.set_modulate(color)

# Check if there is an adjacent block to a given coordinate
func HasAdjacentBlock(coords: Vector2i, placed_blocks: Dictionary) -> bool:
	var adjacent_pos = [
		Vector2i(coords.x + 1, coords.y),
		Vector2i(coords.x - 1, coords.y),
		Vector2i(coords.x, coords.y + 1),
		Vector2i(coords.x, coords.y - 1)
	]
	for pos in adjacent_pos:
		if placed_blocks.has(pos):
			return true
	return false



func _unhandled_input(event):
	var current_tilemap = layer_map[current_layer]
	var clicked_cell = current_tilemap.local_to_map(get_local_mouse_position())

	if event is InputEventMouseButton:
		if get_mouse_ui()== true:
			print_debug("Mouse was in UI unable to place block")
			return
		if event.is_action_pressed("left_click"):
			# Start the timer for detecting hold
			left_click_timer = 0.0
			is_holding = false
			set_process(true)  # Ensure process is enabled for continuous checking
			# Place or replace a block immediately on single-click
			if current_tilemap.get_cell_tile_data(clicked_cell): 
				current_tilemap.set_cell(clicked_cell, main_source, _get_block_id())
			else:
				current_tilemap.set_cell(clicked_cell, main_source, _get_block_id())
		elif event.is_action_released("left_click"):
			if not is_holding:
				# If it was a single click and not a hold, set process to false
				set_process(false)
		if event.is_action_pressed("right_click"):
			set_process(true)
		elif event.is_action_released("right_click"):
			set_process(false)

func _process(delta):
	var current_tilemap = layer_map[current_layer]
	var clicked_cell = current_tilemap.local_to_map(get_local_mouse_position())
	if get_mouse_ui()==true:
		return
	# Check if left-click hold threshold has been reached
	if Input.is_action_pressed("left_click"):
		left_click_timer += delta
		if left_click_timer >= hold_threshold and not is_holding:
			is_holding = true  # Now we’re in "hold mode" for continuous placement
		if is_holding:
			# Only place continuously if the cell is empty
			if not current_tilemap.get_cell_tile_data(clicked_cell):
				current_tilemap.set_cell(clicked_cell, main_source, _get_block_id())
	# Handle continuous removal with right-click
	# Might make a "eraser" for this but this works for now
	if Input.is_action_pressed("right_click"):
		if current_tilemap.get_cell_tile_data(clicked_cell):
			current_tilemap.set_cell(clicked_cell, main_source, Vector2i(-1, -1), -1)
			
