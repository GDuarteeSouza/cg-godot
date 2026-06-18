extends Control

func _ready():
	visible = false

func mostrar():
	visible = true
	get_tree().paused = true

func _on_novo_jogo_button_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_sair_button_pressed():
	get_tree().quit()
