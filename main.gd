extends Node

@onready var menu = $MainMenu
@onready var world = $GameWorld
@onready var game_over = $GameOver

func _ready():
	menu.visible = true
	world.visible = false
	game_over.visible = false

func iniciar_jogo():
	menu.visible = false
	world.visible = true
	game_over.visible = false

func mostrar_game_over():
	menu.visible = false
	world.visible = false
	game_over.visible = true
