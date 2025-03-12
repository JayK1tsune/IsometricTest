extends CanvasGroup
class_name Hud
@export var hud_cube: Blocks

#On ready Functions, if you change the name you need to make sure you change the these.
@export var current_cube: Sprite2D
@export var button_text: Label
# Vars exposed to the inspector 
@export var textureAtlas: AtlasTexture
@export var camera: Camera2D

const imageSlideNumber = 34
var max_x: int
var current_block_id 
var display_block_hud : bool = false
var ghost_position: Vector2i = Vector2i(-1,-1)
var ghost_tile: Vector2i = Vector2i(0,0)
var ghost_sprite: Sprite2D
var current_tilemap
var current_offeset_value : Vector2


var is_mous_in_ui = false

func hud_block_id() :
	return hud_cube.blockId

var frames = {
	0:int(4),
	1:int(38),
	2:int(72),
	3:int(106),
	4:int(140)
}

func _ready():
	current_offeset_value = camera.offset
	current_block_id = hud_block_id()
	max_x = 140
	textureAtlas.region = textureAtlas.get_region()
	print(textureAtlas.region.position.x)
	current_cube.texture = textureAtlas
	
	#make the ghost sprite
	ghost_sprite = Sprite2D.new()
	ghost_sprite.name = "Ghost Sprite"
	ghost_sprite.texture = textureAtlas
	ghost_sprite.modulate = Color(1,1,1,0.3)
	ghost_sprite.visible = false
	add_child(ghost_sprite)
	
func _process(_delta) -> void:
	var mouse_pos = hud_cube.local_to_map(get_local_mouse_position())
	if mouse_pos != ghost_position and display_block_hud:
		ghost_position = mouse_pos
		var world_pos = hud_cube.map_to_local(ghost_position)
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
				hud_cube.blockId = current_block_id
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
				hud_cube.blockId = current_block_id  # Update the map_node's blockId
				print("Updated block ID:", current_block_id)
				break  # Exit the loop once we find a match

	else:
		print("Already at the last frame")

func _on_b_pressed():
	hud_cube.current_layer = hud_cube.Layer.GROUND
func _on_layer_1_pressed():
	hud_cube.current_layer = hud_cube.Layer.LEVEL_1
func _on_layer_2_pressed():
	hud_cube.current_layer = hud_cube.Layer.LEVEL_2


func _on_select_pressed():
	display_block_hud = not display_block_hud
	if display_block_hud == true:
		button_text.text = "HIDE"
	else:
		button_text.text = "SHOW"


func _on_control_mouse_entered():
	print_debug("I'm in and true")
	is_mous_in_ui = true
	
func _on_control_mouse_exited():
	print_debug("i'm out")
	is_mous_in_ui = false

func is_mouse_in_UI():
	return is_mous_in_ui

	pass # Replace with function body.


func rotate_left_button():
	#TODO camer lerp
	camera.offset -= Vector2(current_offeset_value).lerp(Vector2(20,0),1)
	current_offeset_value = camera.offset
	print_debug(current_offeset_value)
	
	print_debug("Left button pressed")
	pass # Replace with function body.


func rotate_right_button():
	camera.offset += Vector2(20,0)
	pass # Replace with function body.
