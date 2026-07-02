extends CanvasLayer

@onready var label = $MarginContainer/HBoxContainer/Label
@onready var container = $MarginContainer

@onready var interact_label = $InteractLabel

func _ready():
	GameManager.show_interaction_message.connect(_on_show_interaction_message)
	GameManager.hide_interaction_message.connect(_on_hide_interaction_message)
	
	GameManager.pendrive_collected.connect(update_label)
	
	if GameManager.has_signal("computer_accessed"):
		GameManager.computer_accessed.connect(_on_computer_accessed)
		
	update_label()

func _on_computer_accessed():
	visible = false

func update_label():
	label.text = str(GameManager.pendrives_collected) + "/6"
	
	if GameManager.pendrives_collected > 0:
		container.show()
	else:
		container.hide()

func _on_show_interaction_message(message: String):
	if interact_label:
		interact_label.text = message
		interact_label.visible = true

func _on_hide_interaction_message():
	if interact_label:
		interact_label.visible = false
