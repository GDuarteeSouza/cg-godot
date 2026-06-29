extends Node

@export var starting_time: float = 240.0

var remaining_time: float
var timer_running := false

func _ready():
	reset_timer()
	if GameManager.has_signal("phase_1_completed"):
		GameManager.phase_1_completed.connect(_on_phase_completed)

func _on_phase_completed():
	reset_timer()

func _process(delta):

	if not timer_running:
		return

	if remaining_time <= 0:
		return

	remaining_time -= delta

	if remaining_time <= 0:
		remaining_time = 0
		game_over()

func start_timer():
	timer_running = true

func stop_timer():
	timer_running = false

func reset_timer():
	remaining_time = starting_time
	timer_running = false

func remove_time(seconds: float):
	remaining_time -= seconds

	if remaining_time < 0:
		remaining_time = 0

func add_time(seconds: float):
	remaining_time += seconds

func game_over():

	var main = get_tree().current_scene

	main.get_node("GameWorld").visible = false
	main.get_node("GameOver").visible = true
