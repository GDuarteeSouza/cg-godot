extends CanvasLayer

@onready var barra = $Control/Panel/MarginContainer/VBoxContainer/ProgressBar
@onready var label_tempo = $Control/Panel/MarginContainer/VBoxContainer/LabelTempo
@onready var label_titulo = $Control/Panel/MarginContainer/VBoxContainer/LabelTitulo

func _ready():
	barra.max_value = GameTimer.starting_time

func _process(_delta):

	barra.value = GameTimer.remaining_time

	var minutos = int(GameTimer.remaining_time) / 60
	var segundos = int(GameTimer.remaining_time) % 60

	label_tempo.text = "%02d:%02d" % [minutos, segundos]

	var porcentagem = GameTimer.remaining_time / GameTimer.starting_time

	if porcentagem <= 0.25:
		barra.modulate = Color.RED
		label_titulo.text = "⚠ TEMPO CRÍTICO"
	elif porcentagem <= 0.50:
		barra.modulate = Color.YELLOW
		label_titulo.text = "⏰ TEMPO RESTANTE"
	else:
		barra.modulate = Color.GREEN
		label_titulo.text = "⏰ TEMPO RESTANTE"
