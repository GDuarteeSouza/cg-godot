extends Node

@export var starting_time: float = 300.0

var remaining_time: float


func _ready():
	reset_timer()


func _process(delta):

	if remaining_time <= 0:
		return

	remaining_time -= delta

	if remaining_time <= 0:
		remaining_time = 0
		game_over()


func reset_timer():
	remaining_time = starting_time


func remove_time(seconds: float):
	remaining_time -= seconds

	if remaining_time < 0:
		remaining_time = 0


func add_time(seconds: float):
	remaining_time += seconds


func game_over():
	print("TEMPO ESGOTADO")
