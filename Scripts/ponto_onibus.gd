extends Area3D

var player_in_area = false
var seta_node: Node3D

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	# Procura a seta na cena automaticamente pelo nome
	var current_scene = get_tree().current_scene
	if current_scene:
		seta_node = _find_node_by_name(current_scene, "seta-ponto-onibus")
		
		# Se não achar por um nome exato, usa o find_child nativo
		if not seta_node:
			seta_node = current_scene.find_child("seta-ponto-onibus", true, false)

func _find_node_by_name(node: Node, target_name: String) -> Node:
	if node.name == target_name:
		return node
	for child in node.get_children():
		var found = _find_node_by_name(child, target_name)
		if found:
			return found
	return null

func _on_body_entered(body):
	if body.name == "Player" or body.is_in_group("player"):
		player_in_area = true
		
		# Esconde a seta
		if seta_node:
			seta_node.visible = false
			
		# Mostra a legenda
		if GameManager.has_user_signal("show_interaction_message") or true:
			GameManager.show_interaction_message.emit("Pressione [F] para pegar o ônibus")

func _on_body_exited(body):
	if body.name == "Player" or body.is_in_group("player"):
		player_in_area = false
		
		# Mostra a seta de novo caso o player saia sem pegar
		if seta_node:
			seta_node.visible = true
			
		# Esconde a legenda
		if GameManager.has_user_signal("hide_interaction_message") or true:
			GameManager.hide_interaction_message.emit()

func _process(delta):
	if player_in_area and Input.is_action_just_pressed("interact"):
		print("Ônibus pego com sucesso!")
		GameManager.hide_interaction_message.emit()
		player_in_area = false # Para não ficar ativando várias vezes
		
		# Mostra a tela de vitória
		GameManager.game_win()
