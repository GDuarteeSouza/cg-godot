extends CharacterBody3D

@export var speed := 2.0
@export var gravity := 9.8

# Tempo de caminhada e encarada
@export var walk_duration := 2.0
@export var stare_duration := 1.0

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

enum State { WALKING, STARING, FINISHED }
var current_state : State = State.WALKING

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	
	if GameManager.has_signal("phase_1_completed"):
		GameManager.phase_1_completed.connect(_on_phase_1_completed)
	
	# Força a lanterna a começar apagada no início do jogo
	if flashlight:
		flashlight.visible = false
	
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
			if nav_agent.is_navigation_finished():
				going_to_b = not going_to_b
				define_novo_destino()
				return

			if not nav_agent.is_target_reachable():
				velocity.x = 0
				velocity.z = 0
				move_and_slide()
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

			# Gira suavemente para encarar o player enquanto estiver parado com a luz acesa
			if player:
				var direction_to_player = (player.global_position - global_position)
				direction_to_player.y = 0
				
				if direction_to_player.length() > 0.2:
					var target_rot = atan2(direction_to_player.x, direction_to_player.z)
					visual.rotation.y = lerp_angle(visual.rotation.y, target_rot, 8.0 * delta)
					
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
