extends CharacterBody2D


const SPEED = 50.0
const JUMP_VELOCITY = -400.0
const TP_SAVE_TIME = 1.5

var remaining_rewind = 5
var history_tick: int = 0;
var position_history: Array = []

func _ready() -> void:
	$Timer.timeout.connect(_on_timer_timeout)
	position_history.append([$".".position, history_tick])
	$rewind_point.top_level = true
	$rewind_point.visible = false
	$Timer.start(TP_SAVE_TIME)
	$AnimatedSprite2D.animation = "default"
	
func _on_timer_timeout() -> void:
	history_tick += 1;
	position_history.append([global_position, history_tick])

func get_nearest_history_position() -> Vector2:
	for history in position_history:
		if (history_tick - history[1] == 1):
			history_tick = history[1]
			return history[0]
	return global_position
	
func check_nearest_history_position() -> Vector2:
	var target_tick = history_tick - 1
	
	for history in position_history:
		if (history[1] == target_tick):
			return history[0]
	return global_position

func _physics_process(delta: float) -> void:
	# Handle jump.
	if Input.is_action_just_pressed("ui_accept"):
		if (remaining_rewind > 0):
			$".".position = get_nearest_history_position()
			remaining_rewind -= 1
		
	var y_directions := Input.get_axis("up", "down")
	var x_directions := Input.get_axis("ui_left", "ui_right")
	if x_directions < 0:
		$AnimatedSprite2D.play("new_animation_1")
	if x_directions > 0:
		$AnimatedSprite2D.animation = "new_animation_1"
		$AnimatedSprite2D.flip_h
		$AnimatedSprite2D.play("new_animation_1")
	if y_directions < 0:
		$AnimatedSprite2D.play("new_animation_2")
	if y_directions > 0:
		$AnimatedSprite2D.play("default")
	if y_directions:
		velocity.y = y_directions * SPEED
	else:
		velocity.y = move_toward(velocity.y, 0, SPEED)
	if x_directions:
		velocity.x = x_directions * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	move_and_slide()
	
	if position_history.size() > 0:
		$rewind_point.visible = true
		$rewind_point/AnimatedSprite2D.play("point")
		$rewind_point.global_position = check_nearest_history_position()
