extends TileMapLayer

@export var gridSize_x_ground = 10  # Ground layer width
@export var gridSize_y_ground = 10  # Ground layer height
@export var gridSize_x_level_1 = 10  # Level 1 width
@export var gridSize_y_level_1 = 10  # Level 1 height
@export var gridSize_x_level_2 = 10  # Level 2 width
@export var gridSize_y_level_2 = 10  # Level 2 height

@onready var ground = $"."  # Ground layer reference
@onready var level_1 = $Level1  # Level 1 reference
@onready var level_2 = $Level2  # Level 2 reference

const TILE_WIDTH = 32  # Width of the tile (horizontal dimension)
const TILE_HEIGHT = 16  # Height of the tile (vertical dimension)
const main_source = 0
const pink_block_atlas_pos = Vector2i(0, 0)
const orange_block_atlas_pos = Vector2i(1, 0)
const purple_block_atlas_pos = Vector2i(2, 0)
const green_block_atlas_pos = Vector2i(3, 0)
const red_block_atlas_pos = Vector2i(4, 0)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Generate the ground layer
	await GenerateLevel(ground, 0, gridSize_x_ground, gridSize_y_ground)
	print_debug("Ground complete")
	
	# Generate level 1
	await GenerateLevel(level_1, 1, gridSize_x_level_1, gridSize_y_level_1)
	print_debug("Level 1 complete")
	
	# Generate level 2
	await GenerateLevel(level_2, 2, gridSize_x_level_2, gridSize_y_level_2)
	print_debug("Level 2 complete")

# Generate blocks for the specified level
func GenerateLevel(level: TileMapLayer, layer_offset: int, gridSize_x: int, gridSize_y: int):
	var placed_blocks = {}
	var first_block_placed = false

	for y in range(gridSize_y):  # Loop through the grid height for this layer
		for x in range(gridSize_x):  # Loop through the grid width for this layer
			var coords = Vector2i(x, y + layer_offset)  # Offset y by layer_offset

			# Ensure the new coordinates are within grid boundaries
			if not placed_blocks.has(coords) and (first_block_placed == false or HasAdjacentBlock(coords, placed_blocks)):
				level.set_cell(coords, main_source, GrabRandomBlock())
				placed_blocks[coords] = true
				first_block_placed = true
				
				# Delay for visual feedback or for other purposes
				const delay := 0.1
				await get_tree().create_timer(delay).timeout
				print_debug("Block placed at x:", coords.x, "y:", coords.y)

	print_debug("Total blocks placed on level:", level.name, "with count:", placed_blocks.size())

# Get a random block from the available options
func GrabRandomBlock() -> Vector2i:
	var cubes = [pink_block_atlas_pos, orange_block_atlas_pos, purple_block_atlas_pos, green_block_atlas_pos, red_block_atlas_pos]
	return cubes.pick_random()

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

# Handle input events for block placement
const SCREEN_WIDTH = 800
const SCREEN_HEIGHT = 600

func _unhandled_input(event):
	if event is InputEventMouseButton and event.is_action_pressed("left_click"):
		#place a block at the mouse pos
		var clicked_cell = ground.local_to_map(ground.get_local_mouse_position())
		print(clicked_cell)
		set_cell(clicked_cell,main_source,GrabRandomBlock())
	if event is InputEventMouseButton and event.is_action_pressed("right_click"):
		var clicked_cell = ground.local_to_map(ground.get_local_mouse_position())
		print("Block removed...")
		set_cell(clicked_cell,main_source,Vector2i(-1,-1),-1)
		
