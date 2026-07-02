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

var intro_game_scene = preload("res://Scenes/IntroGame.tscn")
var intro_fase_2_scene = preload("res://Scenes/IntroFase2.tscn")

func iniciar_jogo():
	menu.visible = false
	game_over.visible = false
	world.visible = false
	timer_ui.visible = false
	
	var intro = intro_game_scene.instantiate()
	add_child(intro)
	intro.intro_finished.connect(_comecar_jogo_real)
	
	GameManager.phase_1_completed.connect(_iniciar_intro_fase_2)

func _iniciar_intro_fase_2():
	world.visible = false
	timer_ui.visible = false
	GameTimer.stop_timer()
	
	var intro2 = intro_fase_2_scene.instantiate()
	add_child(intro2)
	intro2.intro_finished.connect(_comecar_jogo_real)

func _comecar_jogo_real():
	world.visible = true
	timer_ui.visible = true
	GameTimer.reset_timer()
	
	# Pequeno delay antes do jogo valer de verdade para o jogador se preparar
	await get_tree().create_timer(1.5).timeout
	GameTimer.start_timer()


func mostrar_game_over():
	menu.visible = false
	world.visible = false
	game_over.visible = true
	timer_ui.visible = false
	
	# Esconde CanvasLayers adicionais
	if world.has_node("FoodUI"):
		world.get_node("FoodUI").visible = false
	if world.has_node("PendriveUI"):
		world.get_node("PendriveUI").visible = false

	GameTimer.stop_timer()
