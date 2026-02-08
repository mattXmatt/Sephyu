extends Node2D

var time_passed: int = 0
var time_multiplicator: float = 2.0
var electicity_shutdown: bool = false
var key_taken: bool = false
var win: bool = false
var game_over: bool = false

func _ready() -> void:
	start_timer()
	$CanvasLayer/Timer.add_theme_color_override("font_color", Color.BLACK)
	$CanvasLayer/rewind_nb.add_theme_color_override("font_color", Color.BLACK)
	$"Spawn-Door/AnimationPlayer".play("open")
	$key/AnimatedSprite2D.play("idle")
	pass

func start_timer() -> void:
	var timer: Timer = Timer.new()
	timer.name = "GlobalTimer"
	timer.wait_time = 1.0 / time_multiplicator
	timer.one_shot = false
	timer.autostart = true
	timer.timeout.connect(_on_timer_timeout)
	add_child(timer)

func get_converted_time(time: int) -> String:
	var minutes: int = floori(time / 60.0)
	var seconds: int = time % 60
	return "%02d:%02d" % [minutes, seconds]

func update_shutdown() -> void:
	if (electicity_shutdown):
		return
	if ($"Key-Room-Button/Area2D".overlaps_body($Player)):
		if (Input.is_action_just_pressed("interact")):
			electicity_shutdown = true
			$"Key-Door/AnimationPlayer".play("open")
			$"world-color-filter".color = Color(0.294, 0.294, 0.31, 1.0)

func update_key() -> void:
	if (key_taken):
		return
	if ($key/Area2D.overlaps_body($Player)):
		key_taken = true
		$key.visible = false
		$key/AnimatedSprite2D.stop()
		
func update_locked_stairs():
	if (!key_taken):
		return
	if ($"Stairs-Door/Area2D".overlaps_body($Player) && Input.is_action_just_pressed("interact")):
		$"Stairs-Door/AnimationPlayer".play("open")
	
func check_game_end() -> bool:
	if (game_over):
		$CanvasLayer/Timer.text = "GAME OVER"
		$CanvasLayer/Timer.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
		$CanvasLayer/Timer.add_theme_font_size_override("font_size", 100)
		$Player.set_physics_process(false)
		$Player.set_process(false)
		$"GlobalTimer".stop()
		return true
	if (win):
		$CanvasLayer/Timer.text = "WIN"
		$CanvasLayer/Timer.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
		$CanvasLayer/Timer.add_theme_font_size_override("font_size", 100)
		$Player.set_physics_process(false)
		$Player.set_process(false)
		$"GlobalTimer".stop()
		return true
	return false
		
func check_captured_by_guard():
	if (game_over):
		return
	if ($Guard/Area2D.overlaps_body($Player)):
		game_over = true
		
func _on_timer_timeout() -> void:
	time_passed += 1
	var time_str: String = get_converted_time(time_passed)
	$CanvasLayer/Timer.text = "Remaining time: " + str(time_str)
	print("Elapsed time: ", time_str)
	if (time_passed >= 300):
		$"GlobalTimer".stop()
		game_over = true

func display_rewind_remaing():
	$CanvasLayer/rewind_nb.text = "Remaining rewind: " + str($Player.remaining_rewind)

func _process(delta: float) -> void:
	display_rewind_remaing()
	update_shutdown()
	update_key()
	update_locked_stairs()
	check_captured_by_guard()
	if ($Stairs/Area2D.overlaps_body($Player)):
		win = true
	if(check_game_end()):
		return
	pass
