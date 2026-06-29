extends CanvasLayer

@onready var cup_container = $MarginContainer/VBoxContainer/CupContainer
@onready var cake_container = $MarginContainer/VBoxContainer/CakeContainer

func _ready():
	GameManager.cup_collected.connect(update_ui)
	GameManager.cake_collected.connect(update_ui)
	update_ui()

func _process(delta):
	visible = GameTimer.timer_running

func update_ui():
	if GameManager.cup_found:
		cup_container.hide()
	else:
		cup_container.show()
		
	if GameManager.cake_found:
		cake_container.hide()
	else:
		cake_container.show()
