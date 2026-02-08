extends Node2D

var time_passed: int = 0
var time_multiplicator: float = 2.0
var electicity_shutdown: bool = false
var key_taken: bool = false
var win: bool = false
var game_over: bool = false
var remaining_rewind = 5

func _ready() -> void:
	start_timer()
	$"Spawn-Door/AnimationPlayer".play("open")
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
		
func update_locked_stairs():
	if (!key_taken):
		return
	if ($"Stairs-Door/Area2D".overlaps_body($Player) && Input.is_action_just_pressed("interact")):
		$"Stairs-Door/AnimationPlayer".play("open")
	
func check_game_end():
	if (game_over):
		get_viewport().gui_disable_input = true
	if (win):
		get_viewport().gui_disable_input = true
func _on_timer_timeout() -> void:
	time_passed += 1
	var time_str: String = get_converted_time(time_passed)
	$CanvasLayer/Label.text = time_str
	print("Elapsed time: ", time_str)
	if (time_passed >= 300):
		$"GlobalTimer".stop()
		game_over = true

func _process(delta: float) -> void:
	check_game_end()
	update_shutdown()
	update_key()
	update_locked_stairs()
	if ($Stairs/Area2D.overlaps_body($Player)):
		win = true
	pass
