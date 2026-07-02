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

	# Cria a label de interação dinamicamente
	_create_interact_label()

	# Conecta os sinais
	sleep_manager.sleep_changed.connect(_on_sleep_changed)
	sleep_manager.player_fell_asleep.connect(_on_player_fell_asleep)
	
	GameManager.show_interaction_message.connect(_on_show_interaction_message)
	GameManager.hide_interaction_message.connect(_on_hide_interaction_message)

var interact_label: Label

func _create_interact_label():
	interact_label = Label.new()
	interact_label.visible = false
	interact_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	interact_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	# Configurar a posição na tela (inferior central)
	interact_label.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	interact_label.position.y -= 100
	
	# Adiciona um estilo básico para ficar legível
	interact_label.add_theme_font_size_override("font_size", 24)
	interact_label.add_theme_color_override("font_outline_color", Color.BLACK)
	interact_label.add_theme_constant_override("outline_size", 4)
	
	add_child(interact_label)

func _on_show_interaction_message(message: String):
	if interact_label:
		interact_label.text = message
		interact_label.visible = true

func _on_hide_interaction_message():
	if interact_label:
		interact_label.visible = false


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
