extends CanvasLayer

@onready var sleep_manager = $"../SleepManager"

@onready var fade_rect = $FadeRect
@onready var sleep_bar = $Sleep/Control/Panel/MarginContainer/VBoxContainer/SleepBar


func _ready():

	# Configuração inicial da barra
	sleep_bar.min_value = 0
	sleep_bar.max_value = sleep_manager.max_sleep
	sleep_bar.value = sleep_manager.current_sleep

	# Tela inicia totalmente clara
	var color = fade_rect.color
	color.a = 0.0
	fade_rect.color = color

	# Conecta os sinais
	sleep_manager.sleep_changed.connect(_on_sleep_changed)
	sleep_manager.player_fell_asleep.connect(_on_player_fell_asleep)


func _on_sleep_changed(value):

	# Atualiza a barra
	sleep_bar.value = value

	# Só começa a escurecer abaixo de 50%
	var alpha := 0.0

	if value < 50.0:
		alpha = (50.0 - value) / 50.0

	alpha = clamp(alpha * 0.9, 0.0, 0.9)

	var color = fade_rect.color
	color.a = alpha
	fade_rect.color = color


func _on_player_fell_asleep():

	print("GAME OVER - Dormiu")

	# Aqui você coloca sua tela de Game Over.
	# Exemplo:
	# get_tree().change_scene_to_file("res://Scenes/game_over.tscn")
