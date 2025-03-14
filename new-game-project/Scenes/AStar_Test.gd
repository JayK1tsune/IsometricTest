extends Node2D
class_name Astar_Script
@export var t: Blocks

@export var path_start_pos = Vector2i()
@export var path_end_poos = Vector2i()
@export var pathColour: Color
@onready var path_line = $"../PathLine"

const path_taken_atals_cords = Vector2i(4,0)

func _ready():
	path_line.width = 4.0
	path_line.default_color = Color(1, 1, 1, 1)  # White
	path_line.antialiased = true


func ShowPath():
	path_line.clear_points()
	path_line.default_color = pathColour  # Use the chosen path color
	
	var path = t.astar.get_id_path(path_start_pos, path_end_poos)	
	
	for cell in path:
		var world_position = t.map_to_local(cell)
		path_line.add_point(world_position)  # Add the path point
	path_line.visible = true
