extends CanvasGroup

@onready var sprite_2d = $CanvasLayer/Menu/BoxContainer/Sprite2D
@export var textureAtlas: AtlasTexture
@export var map_node : Node2D
const imageSlideNumber = 34
var max_x: int
var current_block_id 

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
