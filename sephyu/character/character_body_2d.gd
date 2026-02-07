extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0


func _physics_process(delta: float) -> void:

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	var directions := Input.get_axis("up", "down")
	var direction := Input.get_axis("ui_left", "ui_right")
	if directions:
		velocity.y = directions * SPEED
	else:
		velocity.y = move_toward(velocity.y, 0, SPEED)
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
