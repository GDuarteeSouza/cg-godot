extends Node3D

func _process(delta):
	# Fica visível APENAS DEPOIS do checkpoint 2 e ATÉ completar o checkpoint 3
	if GameManager.checkpoint_2_reached and not GameManager.checkpoint_3_reached:
		visible = true
	else:
		visible = false
