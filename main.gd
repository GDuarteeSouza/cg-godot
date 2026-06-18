extends Node

@onready var menu = $MainMenu
@onready var world = $GameWorld
@onready var game_over = $GameOver
@onready var timer_ui = $GameWorld/TimerUi

func _ready():

	menu.visible = true
	world.visible = false
	game_over.visible = false
	timer_ui.visible = false

	GameTimer.reset_timer()

func iniciar_jogo():

	menu.visible = false
	world.visible = true
	game_over.visible = false
	timer_ui.visible = true

	GameTimer.reset_timer()
	GameTimer.start_timer()

func mostrar_game_over():

	menu.visible = false
	world.visible = false
	game_over.visible = true
	timer_ui.visible = false

	GameTimer.stop_timer()
