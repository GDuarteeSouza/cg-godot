extends Node

var danger_level := 0

func add_danger():

	danger_level += 1

	print("PERIGO:", danger_level)

	if danger_level >= 3:

		game_over()

func game_over():

	print("GAME OVER")
