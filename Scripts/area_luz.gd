extends Area3D

@onready var sleep = get_tree().get_first_node_in_group("sleep_manager")

func _on_body_entered(body):

	if body.is_in_group("player"):
		sleep.inside_light = true
		print("Entrou na luz")

func _on_body_exited(body):

	if body.is_in_group("player"):
		sleep.inside_light = false
		print("Saiu da luz")
