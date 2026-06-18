extends Node

@export var max_warnings := 3
@export var decay_time := 30.0

var warnings := 0

var decay_timer : Timer


func _ready():

	decay_timer = Timer.new()
	add_child(decay_timer)

	decay_timer.one_shot = false
	decay_timer.wait_time = decay_time

	decay_timer.timeout.connect(_on_decay_timeout)

	decay_timer.start()


func add_warning():

	warnings += 1

	print("Advertências: ", warnings)

	if warnings >= max_warnings:
		game_over()


func _on_decay_timeout():

	if warnings > 0:

		warnings -= 1

		print("Advertências diminuíram para: ", warnings)


func game_over():

	get_tree().paused = true

	var ui = get_tree().get_first_node_in_group("game_over_ui")

	if ui:
		ui.show_game_over()


func restart_game():

	warnings = 0

	get_tree().paused = false

	get_tree().reload_current_scene()
