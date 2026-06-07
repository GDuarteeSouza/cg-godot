extends CharacterBody3D

@export var speed_walk := 2.0
@export var speed_run := 5.0
@export var gravity := 14.0 # Gravidade firme para cair rápido após o pulo
@export var jump_velocity := 7.5 # Força ideal para cruzar o buraco horizontalmente

var player: Node3D = null

enum State { IDLE, CHASING, ATTACKING }
var current_state : State = State.IDLE

@onready var agent: NavigationAgent3D = $NavigationAgent3D
@onready var detection_area: Area3D = $DetectionArea
@onready var attack_area: Area3D = $AttackArea
@onready var anim_tree: AnimationTree = $AnimationTree
@onready var visual = $DogModel 

func _ready() -> void:
	agent.target_desired_distance = 0.6
	agent.path_max_distance = 3.0
	
	detection_area.body_entered.connect(_on_detection_entered)
	detection_area.body_exited.connect(_on_detection_exited)
	attack_area.body_entered.connect(_on_attack_entered)
	
	if anim_tree:
		anim_tree.active = true

func _physics_process(delta: float) -> void:
	# Aplica gravidade normal se estiver no ar
	if not is_on_floor():
		velocity.y -= gravity * delta

	match current_state:
		State.IDLE:
			if is_on_floor():
				velocity.x = 0
				velocity.z = 0
			update_animation_state("idle")
			
		State.CHASING:
			if player and agent:
				agent.target_position = player.global_position
				
				var next_position = agent.get_next_path_position()
				var direction = (next_position - global_position)
				direction.y = 0 
				direction = direction.normalized()

				# Movimento horizontal
				velocity.x = direction.x * speed_run
				velocity.z = direction.z * speed_run
				
				# Garante que a animação de corrida fique travada enquanto persegue no chão
				if is_on_floor():
					update_animation_state("run")

				# ROTAÇÃO ABSOLUTA (Olhar de Frente):
				# Corrigindo matematicamente o modelo invertido usando o '+ PI' (180 graus)
				var dir_to_player = (player.global_position - global_position)
				dir_to_player.y = 0
				if dir_to_player.length() > 0.1:
					var target_rotation = atan2(dir_to_player.x, dir_to_player.z) + PI
					visual.rotation.y = lerp_angle(visual.rotation.y, target_rotation, 12.0 * delta)

				# INTELIGÊNCIA DE SALTO ANTI-BURACO:
				# Se ele colidir com uma parede (is_on_wall) OU se o próximo ponto do caminho indicar
				# uma alteração brusca de relevo/vão, ele pula.
				var subindo_bloco = (next_position.y - global_position.y) > 0.3
				var na_beirada_do_vao = _detectar_vao_a_frente(direction)

				if (subindo_bloco or is_on_wall() or na_beirada_do_vao) and is_on_floor():
					velocity.y = jump_velocity

		State.ATTACKING:
			if is_on_floor():
				velocity.x = 0
				velocity.z = 0
			update_animation_state("attacking")

	move_and_slide()

# Função esperta: projeta um ponto à frente no chão para ver se o cachorro vai cair no buraco
func _detectar_vao_a_frente(dir: Vector3) -> bool:
	if dir == Vector3.ZERO:
		return false
	
	# Verifica se a próxima posição do NavMesh está muito distante da horizontal atual
	# Isso acusa que a rota pulou por cima de um espaço vazio
	var distancia_proximo_ponto = global_position.distance_to(agent.get_next_path_position())
	if distancia_proximo_ponto > 2.0 and not agent.is_navigation_finished():
		return true
		
	return false

func _on_detection_entered(body: Node3D) -> void:
	if body.is_in_group("player") and current_state != State.ATTACKING:
		player = body
		current_state = State.CHASING

func _on_detection_exited(body: Node3D) -> void:
	if body == player and current_state != State.ATTACKING:
		player = null
		current_state = State.IDLE

func _on_attack_entered(body: Node3D) -> void:
	if body.is_in_group("player") and current_state != State.ATTACKING:
		current_state = State.ATTACKING
		update_animation_state("attacking")
		game_over()

func game_over() -> void:
	print("🚨 GAME OVER: O cachorro te pegou!")

func update_animation_state(state_name: String) -> void:
	if not anim_tree:
		return
	anim_tree.set("parameters/conditions/is_idle", state_name == "idle")
	anim_tree.set("parameters/conditions/is_walking", state_name == "walk")
	anim_tree.set("parameters/conditions/is_running", state_name == "run")
	anim_tree.set("parameters/conditions/is_attacking", state_name == "attacking")
