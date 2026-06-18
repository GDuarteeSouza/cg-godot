extends Control

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass

func _on_novo_jogo_button_pressed() -> void:
	get_tree().current_scene.iniciar_jogo()

func _on_creditos_button_pressed() -> void:
	pass

func _on_exit_button_pressed() -> void:
	get_tree().quit()
