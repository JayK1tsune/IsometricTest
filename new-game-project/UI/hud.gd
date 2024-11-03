extends CanvasGroup

@onready var sprite_2d = $Control/CanvasLayer/Menu/BoxContainer/Sprite2D
@export var textureAtlas: AtlasTexture
@export var map_node : Node2D
const imageSlideNumber = 34
var max_x: int
var current_block_id 
var display_block_hud : bool = false
var ghost_position: Vector2i = Vector2i(-1,-1)
var ghost_tile: Vector2i = Vector2i(0,0)
var ghost_sprite: Sprite2D
@onready var label_text = $Control/CanvasLayer/Menu/BoxContainer/Select/Label

var frames = {
	0:int(4),
	1:int(38),
	2:int(72),
	3:int(106),
	4:int(140)
}

func _ready():
	current_block_id = map_node.blockId
	max_x = 140
	textureAtlas.region = textureAtlas.get_region()
	print(textureAtlas.region.position.x)
	sprite_2d.texture = textureAtlas
	
	#make the ghost sprite
	ghost_sprite = Sprite2D.new()
	ghost_sprite.texture = textureAtlas
	ghost_sprite.modulate = Color(1,1,1,0.3)
	ghost_sprite.visible = false
	add_child(ghost_sprite)
	
func _process(_delta) -> void:
	var current_tilemap = map_node.layer_map[map_node.current_layer]
	var mouse_pos = current_tilemap.local_to_map(get_local_mouse_position())
	if mouse_pos != ghost_position and display_block_hud:
		ghost_position = mouse_pos
		var world_pos = current_tilemap.map_to_local(ghost_position)
		ghost_sprite.position = world_pos
		ghost_sprite.visible = true
	if display_block_hud == false:
		ghost_sprite.visible = false

func _on_back_pressed():
	if textureAtlas.region.position.x > 4:
		textureAtlas.region.position.x -= imageSlideNumber

		# Check if the new position.x is in the frames values
		for block_id in frames:
			if frames[block_id] == textureAtlas.region.position.x:
				current_block_id = block_id
				map_node.blockId = current_block_id  # Update the map_node's blockId
				print("Updated block ID:", current_block_id)
				break  # Exit the loop once we find a match

		print("Moved Back")
	else:
		print("Already at the first frame")

func _on_next_pressed():
	if textureAtlas.region.position.x < max_x :
		textureAtlas.region.position.x += imageSlideNumber
		for block_id in frames:
			if frames[block_id] == textureAtlas.region.position.x:
				current_block_id = block_id
				map_node.blockId = current_block_id  # Update the map_node's blockId
				print("Updated block ID:", current_block_id)
				break  # Exit the loop once we find a match

	else:
		print("Already at the last frame")

func _on_b_pressed():
	map_node.current_layer = map_node.Layer.GROUND
func _on_layer_1_pressed():
	map_node.current_layer = map_node.Layer.LEVEL_1
func _on_layer_2_pressed():
	map_node.current_layer = map_node.Layer.LEVEL_2


func _on_select_pressed():
	display_block_hud = not display_block_hud
	if display_block_hud == true:
		label_text.text = "HIDE"
	else:
		label_text.text = "SHOW"


func _on_control_mouse_entered():
	print("i'm in")


func _on_control_mouse_exited():
	print("i'm out")
