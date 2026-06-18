extends Control

@export var game : PackedScene

func _ready() -> void:
	pass 

func _process(delta: float) -> void:
	pass

func _on_novo_jogo_button_pressed() -> void:
	get_tree().change_scene_to_packed(game)


func _on_creditos_button_pressed() -> void:
	pass # Replace with function body.


func _on_exit_button_pressed() -> void:
	get_tree().quit()
