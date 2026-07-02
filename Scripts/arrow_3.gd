extends Node3D

func _process(delta):
	# Aparece quando tiver 6 pendrives e desaparece no checkpoint-fase-2-1
	if GameManager.pendrives_collected >= 6 and not GameManager.checkpoint_fase_2_1_reached:
		visible = true
	else:
		visible = false
