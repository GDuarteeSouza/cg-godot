extends Node3D

@export_enum("Arrow 1 (Sobe no inicio, some no Checkpoint 2)", "Arrow 2 (Aparece no Checkpoint 2, some no Checkpoint 3)") var arrow_type: int = 0

func _process(delta):
	if arrow_type == 0:
		# Arrow 1 fica visível do começo até o player passar pelo checkpoint 2
		visible = not GameManager.checkpoint_2_reached
	else:
		# Arrow 2 fica visível APENAS DEPOIS do checkpoint 2 e ATÉ completar o checkpoint 3
		if GameManager.checkpoint_2_reached and not GameManager.checkpoint_3_reached:
			visible = true
		else:
			visible = false
