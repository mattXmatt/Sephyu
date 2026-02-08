extends CharacterBody2D

@export var speed := 30.0
@export var wait_time := 0.6
@export var patrol_points_path: NodePath
@export var arrive_distance := 6.0
@export var vision_distance := 160.0
@export var fov_degrees := 60.0
@export var player_group := "player"

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var lamp_ray: AnimatedSprite2D = $LightRay
@onready var ray: RayCast2D = $RayCast2D
@onready var vision_area: Area2D = $VisionArea

var points: Array[Vector2] = []
var current_point := 0
var direction := 1
var waiting := false
var facing_dir := Vector2.RIGHT
var player: Node2D = null

func _ready():
	var holder = get_node(patrol_points_path)
	for c in holder.get_children():
		if c is Node2D:
			points.append(c.global_position)

	if points.size() < 2:
		push_error("error: patrol points niark niark")
		set_physics_process(false)
		return

	anim.play("idle")
	lamp_ray.play("default")

func _physics_process(delta):
	_patrol()
	_update_lamp_ray()
	_update_animation()
	_check_player()

func _patrol():
	if waiting:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var target := points[current_point]
	var dir := target - global_position

	if dir.length() < arrive_distance:
		_pause_and_turn()
		return

	velocity = dir.normalized() * speed
	facing_dir = velocity.normalized()
	_flip_sprites()
	if (move_and_slide()):
		_check_wall_collision()

func _check_wall_collision():
	var collision_count = get_slide_collision_count()

	if collision_count > 0:
		var collision = get_last_slide_collision()
		if collision.get_normal().dot(facing_dir) < -0.5:
			_handle_wall_bounce()
			
func _handle_wall_bounce():
	waiting = true
	velocity = Vector2.ZERO    
	direction *= -1
	current_point += direction
	if current_point < 0:
		current_point = 1
		direction = 1
	elif current_point >= points.size():
		current_point = points.size() - 2
		direction = -1 
	await get_tree().create_timer(wait_time).timeout
	waiting = false

func _pause_and_turn():
	waiting = true
	velocity = Vector2.ZERO
	move_and_slide()

	current_point += direction
	if current_point >= points.size() - 1:
		current_point = points.size() - 1
		direction = -1
	elif current_point <= 0:
		current_point = 0
		direction = 1

	var next_dir = (points[current_point] - global_position).normalized()
	facing_dir = next_dir
	_flip_sprites()

	await get_tree().create_timer(wait_time).timeout
	waiting = false

func _flip_sprites():
	if abs(facing_dir.x) > abs(facing_dir.y):
		var flip := facing_dir.x < 0
		anim.flip_h = flip
		lamp_ray.flip_h = flip

func _update_lamp_ray():
	lamp_ray.rotation = facing_dir.angle()

func _update_animation():
	if velocity.length() > 1.0:
		if anim.animation != "walk_right":
			anim.play("walk_right")
	else:
		if anim.animation != "idle":
			anim.play("idle")

func _on_body_entered(body):
	if body.is_in_group(player_group):
		player = body

func _on_body_exited(body):
	if body == player:
		player = null

func _check_player():
	if player == null:
		return

	var to_player := player.global_position - global_position
	var dist := to_player.length()
	if dist > vision_distance:
		return

	var dir: Vector2 = to_player.normalized()
	var angle: float = abs(facing_dir.normalized().angle_to(dir))
	if angle > deg_to_rad(fov_degrees * 0.5):
		return

	ray.global_position = global_position
	ray.target_position = to_player
	ray.force_raycast_update()

	if ray.is_colliding() and ray.get_collider() != player:
		return

	get_tree().reload_current_scene()
