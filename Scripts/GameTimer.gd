extends Node

@export var starting_time: float = 240.0

var remaining_time: float
var game_over_ativado := false

func _ready():
	reset_timer()

func _process(delta):

	if game_over_ativado:
		return

	remaining_time -= delta

	if remaining_time <= 0:
		remaining_time = 0
		game_over()

func reset_timer():
	remaining_time = starting_time
	game_over_ativado = false

func remove_time(seconds: float):

	if game_over_ativado:
		return

	remaining_time -= seconds

	if remaining_time <= 0:
		remaining_time = 0
		game_over()

func add_time(seconds: float):

	if game_over_ativado:
		return

	remaining_time += seconds

func game_over():

	if game_over_ativado:
		return

	game_over_ativado = true

	print("GAME OVER")

	var main = get_tree().current_scene

	main.get_node("GameWorld").visible = false

	var tela_game_over = main.get_node("GameOver")

	if tela_game_over.has_method("mostrar"):
		tela_game_over.mostrar()
	else:
		tela_game_over.visible = true
