extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0


func _physics_process(delta):

	var direction = Input.get_vector("ui_left", "ui_right","ui_up","ui_down")
	if direction:
		self.velocity = direction * SPEED
	else:
		self.velocity = Vector2.ZERO

	move_and_slide()
