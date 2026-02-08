extends Node2D

var time_passed: int = 0
var time_multiplicator: float = 2.0

func _ready() -> void:
	$Timer.timeout.connect(_on_timer_timeout)
	$Timer.start(4)
	start_timer()
	pass

func start_timer() -> void:
	var timer: Timer = Timer.new()
	timer.wait_time = 1.0 / time_multiplicator
	timer.one_shot = false
	timer.autostart = true
	timer.timeout.connect(_on_timer_timeout_)
	add_child(timer)

func get_converted_time(time: int) -> String:
	var minutes: int = floori(time / 60.0)
	var seconds: int = time % 60
	return "%02d:%02d" % [minutes, seconds]


func _on_timer_timeout_() -> void:
	time_passed += 1
	var time_str: String = get_converted_time(time_passed)
	$CanvasLayer/Label.text = time_str
	print("Elapsed time: ", time_str)

func _on_timer_timeout() -> void:
	$Timer.stop()
	$"East-Doors/AnimationPlayer".play("open")
	$"East-Doors2/AnimationPlayer".play("open")
	$"East-Doors3/AnimationPlayer".play("open")
	$"world-color-filter".color = Color(0.294, 0.294, 0.31, 1.0)
	pass

func _process(delta: float) -> void:
	pass
