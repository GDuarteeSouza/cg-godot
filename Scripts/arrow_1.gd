extends Node3D

func _process(delta):
	# Fica visível do começo até o player passar pelo checkpoint 2
	visible = not GameManager.checkpoint_2_reached
