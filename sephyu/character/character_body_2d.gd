extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0


func _physics_process(delta: float) -> void:

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	var y_directions := Input.get_axis("up", "down")
	var x_directions := Input.get_axis("ui_left", "ui_right")
	if y_directions:
		velocity.y = y_directions * SPEED
	else:
		velocity.y = move_toward(velocity.y, 0, SPEED)
	if x_directions:
		velocity.x = x_directions * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
