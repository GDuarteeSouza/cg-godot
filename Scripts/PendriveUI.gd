extends CanvasLayer

@onready var label = $MarginContainer/HBoxContainer/Label
@onready var container = $MarginContainer

func _ready():
	GameManager.pendrive_collected.connect(update_label)
	update_label()

func update_label():
	label.text = str(GameManager.pendrives_collected) + "/6"
	
	if GameManager.pendrives_collected > 0:
		container.show()
	else:
		container.hide()
