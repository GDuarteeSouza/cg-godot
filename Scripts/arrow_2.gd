extends Node3D

func _process(delta):
	# Fica visível assim que coletar 6 pendrives e some ao completar o checkpoint-fase-2-1
	if GameManager.pendrives_collected >= 6 and not GameManager.checkpoint_fase_2_1_reached:
		visible = true
	else:
		visible = false
