extends CharacterBody3D

@export var speed := 2.0
@export var gravity := 9.8

# Tempo de caminhada e encarada
@export var walk_duration := 2.0
@export var stare_duration := 3.0

# Nós de destino do cenário (piso_teste.scn)
@export var point_a : Marker3D
@export var point_b : Marker3D

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var visual = $Visual
@onready var timer: Timer = $Timer
@onready var flashlight: SpotLight3D = $SpotLight3D
@onready var anim_tree = $AnimationTree

var player : Node3D
var going_to_b := true
var target_dirty := false

enum State { WALKING, STARING, FINISHED }
var current_state : State = State.WALKING

func _ready() -> void:
	var all_players = get_tree().get_nodes_in_group("player")
	for p in all_players:
		if p is Node3D and ("is_crouching" in p or p.has_method("face_target")):
			player = p
			break
	
	if GameManager.has_signal("phase_1_completed"):
		GameManager.phase_1_completed.connect(_on_phase_1_completed)
	
	# Força a lanterna a começar apagada no início do jogo
	if flashlight:
		flashlight.visible = false
		if flashlight.get_parent() != visual:
			flashlight.reparent(visual, true)
	
	# Margens seguras de navegação para o tamanho atual do boneco
	nav_agent.target_desired_distance = 1.0
	nav_agent.path_max_distance = 3.0
	nav_agent.navigation_layers = 1 

	if not point_a or not point_b:
		push_error("ERRO: Os pontos continuam vazios no Inspector!")
		return

	global_position = point_a.global_position
	
	await get_tree().physics_frame
	await get_tree().physics_frame
	
	define_novo_destino()

	# Configura o Timer de loop
	timer.one_shot = true
	timer.timeout.connect(_on_timer_timeout)
	timer.start(walk_duration)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0

	match current_state:
		State.WALKING:
			if target_dirty:
				target_dirty = false
			elif nav_agent.is_navigation_finished():
				going_to_b = not going_to_b
				define_novo_destino()
				return

			var next_path_pos = nav_agent.get_next_path_position()
			var direction = (next_path_pos - global_position)
			direction.y = 0
			direction = direction.normalized()

			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
			move_and_slide()

			if direction.length() > 0.1:
				var target_rot = atan2(direction.x, direction.z)
				visual.rotation.y = lerp_angle(visual.rotation.y, target_rot, 6.0 * delta)

		State.STARING:
			velocity.x = 0
			velocity.z = 0
			move_and_slide()

			# Calcula oscilação (varredura) que inicia em 0 e vai até ~45 graus pros lados
			var oscilacao = sin((stare_duration - timer.time_left) * 6.0) * 0.8

			# Gira suavemente para encarar a direção geral do player com a varredura ativa
			if player:
				var direction_to_player = (player.global_position - global_position)
				direction_to_player.y = 0
				
				if direction_to_player.length() > 0.2:
					# Rotaciona para o jogador e aplica a oscilação
					var target_rot = atan2(direction_to_player.x, direction_to_player.z) + oscilacao
					visual.rotation.y = lerp_angle(visual.rotation.y, target_rot, 8.0 * delta)
			
			# Detecção do jogador dentro do feixe de luz da lanterna só ocorre se o jogo estiver valendo (timer_running)
			if flashlight and flashlight.visible and GameTimer.timer_running:
				# Pega o jogador real, não um node aleatório do grupo
				var current_player = null
				for p in get_tree().get_nodes_in_group("player"):
					if p.has_method("face_target") or "is_crouching" in p:
						current_player = p
						break
				
				if current_player:
					# Se o jogador estiver agachado, ele não é detectado
					var player_crouching = false
					if "is_crouching" in current_player:
						player_crouching = current_player.is_crouching
					
					if not player_crouching:
						var player_center = current_player.global_position + Vector3(0, 1.0, 0)
						var dir_to_player = player_center - flashlight.global_position
						var dist = dir_to_player.length()
						
						if dist <= flashlight.spot_range:
							var forward = -flashlight.global_transform.basis.z
							var angle = forward.angle_to(dir_to_player.normalized())
							
							# SpotLight3D.spot_angle é metade do ângulo total do cone (em graus)
							if angle <= deg_to_rad(flashlight.spot_angle):
								# Raycast triplo (cabeça, centro, pés) para evitar falsos negativos com mesas/obstáculos baixos
								var space_state = get_world_3d().direct_space_state
								var targets = [
									current_player.global_position + Vector3(0, 0.3, 0),  # Pés/Baixo
									current_player.global_position + Vector3(0, 1.0, 0),  # Centro
									current_player.global_position + Vector3(0, 1.7, 0)   # Cabeça/Alto
								]
								
								var excludes = []
								excludes.append(self.get_rid())
								for child in get_children():
									if child is CollisionObject3D:
										excludes.append(child.get_rid())
								
								var detected = false
								for target_pos in targets:
									var query = PhysicsRayQueryParameters3D.create(flashlight.global_position, target_pos)
									query.exclude = excludes
									var result = space_state.intersect_ray(query)
									
									if result and result.collider == current_player:
										detected = true
										break
								
								if detected:
									print("Jogador detectado na luz do professor! Game Over!")
									GameManager.game_over()
					
		State.FINISHED:
			velocity.x = 0
			velocity.z = 0
			move_and_slide()
			# Ele vai ficar parado olhando para a turma.
			# Como ele apenas para de andar, ele continua olhando para onde estava.


func define_novo_destino() -> void:
	if going_to_b:
		nav_agent.target_position = point_b.global_position
	else:
		nav_agent.target_position = point_a.global_position
	target_dirty = true

func _on_timer_timeout() -> void:
	if current_state == State.WALKING:
		# Transiciona para encarar
		current_state = State.STARING
		
		if flashlight:
			flashlight.visible = true
			
		# Descobre se o player está mais para a esquerda ou direita para tocar a animação certa
		if player:
			var local_player = visual.to_local(player.global_position)
			if local_player.x > 0:
				trigger_animation("turn_right")
			else:
				trigger_animation("turn_left")
		
		timer.start(stare_duration)
	else:
		# Volta a andar
		current_state = State.WALKING
		
		if flashlight:
			flashlight.visible = false
			
		timer.start(walk_duration)

func trigger_animation(condition_name: String) -> void:
	if anim_tree:
		anim_tree.set("parameters/conditions/" + condition_name, true)
		await get_tree().process_frame
		anim_tree.set("parameters/conditions/" + condition_name, false)

func _on_phase_1_completed() -> void:
	current_state = State.FINISHED
	if flashlight:
		flashlight.visible = false
	timer.stop()
