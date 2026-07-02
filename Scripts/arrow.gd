extends Node3D

@export_enum("Arrow 1 (Sobe no inicio, some no Checkpoint 2)", "Arrow 2 (Aparece no Checkpoint 2, some no Checkpoint 3)") var arrow_type: int = 0

func _process(delta):
	if arrow_type == 0:
		# Arrow 1 fica visível do começo até o player passar pelo checkpoint 2
		visible = not GameManager.checkpoint_2_reached
	else:
		# Arrow 2 fica visível assim que tiver 6 pendrives e ATÉ completar o checkpoint-fase-2-1
		if GameManager.pendrives_collected >= 6 and not GameManager.checkpoint_fase_2_1_reached:
			visible = true
		else:
			visible = false
