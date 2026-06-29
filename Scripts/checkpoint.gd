extends Area3D

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D):
	if body.name != "Player":
		return
		
	# Usa "in name" para funcionar mesmo se o nó se chamar "checkpoint-fase-1-1", "Checkpoint-1-1", etc.
	if "1-1" in name or "1_1" in name:
		if not GameManager.checkpoint_1_reached:
			GameManager.checkpoint_1_reached = true
			print("Checkpoint 1 alcançado!")
			
	elif "1-2" in name or "1_2" in name:
		if GameManager.checkpoint_1_reached:
			if not GameManager.checkpoint_2_reached:
				GameManager.checkpoint_2_reached = true
				print("Checkpoint 2 alcançado!")
		else:
			print("Você precisa passar pelo Checkpoint 1 primeiro!")
			
	elif "1-3" in name or "1_3" in name:
		# Se ele ainda não pegou o checkpoint 2, ele só está no inicio da fase, então ignora a mensagem.
		if not GameManager.checkpoint_2_reached:
			return 
			
		if GameManager.cup_found and GameManager.cake_found:
			print("Fase 1 completada com sucesso!")
			GameManager.checkpoint_3_reached = true
			GameManager.complete_phase_1()
			# Desativa o checkpoint para não ficar avisando várias vezes
			queue_free()
		else:
			print("Você precisa coletar o café e o bolo antes de terminar!")
