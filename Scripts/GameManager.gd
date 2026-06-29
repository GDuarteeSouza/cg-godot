extends Node

@export var starting_time: float = 120.0

var remaining_time: float
var timer_running := false

signal pendrive_collected
var pendrives_collected: int = 0

signal cup_collected
signal cake_collected
var cup_found: bool = false
var cake_found: bool = false

var checkpoint_1_reached: bool = false
var checkpoint_2_reached: bool = false
var checkpoint_3_reached: bool = false
signal phase_1_completed

func _ready():
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

func collect_pendrive():
	pendrives_collected += 1
	pendrive_collected.emit()

func collect_cup():
	cup_found = true
	cup_collected.emit()

func collect_cake():
	cake_found = true
	cake_collected.emit()

func complete_phase_1():
	print("Fase 1 completada com sucesso!")
	phase_1_completed.emit()
