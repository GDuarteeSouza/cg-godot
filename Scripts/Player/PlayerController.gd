extends CharacterBody3D

@export var speed := 5.0
@export var run_speed := 8.0
@export var crouch_speed := 2.0
@export var jump_force := 4.5
@export var gravity := 9.8

#=====================================
# WALL CLIMB & INTERACT
#=====================================

@export var climb_speed := 2.5

var anim_tree
var collider

@onready var visual = $Skeleton3D
@onready var wall_check: RayCast3D = $WallCheck
@onready var top_check: RayCast3D = $TopCheck

# Nós para o sistema de empurrar
@onready var interaction_ray: RayCast3D = $InteractionRay
@onready var attachment_joint: Generic6DOFJoint3D = $AttachmentJoint

var is_crouching = false
var is_running = false
var is_jumping = false
var is_embarrassed = false
var is_wall_climbing = false
var is_wall_vaulting = false # Controla o estado de parkour/pular muro
var _was_touching_wall = false 
var mud_multiplier := 1.0     

# Variáveis do sistema de empurrar/puxar
var is_pushing = false
var is_pulling = false
var current_box: RigidBody3D = null

var jump_delay_timer := 0.0

# =========================
# SISTEMA DE BLOQUEIO
# =========================

var controls_locked := false
var lock_source: String = ""


func _ready():
	add_to_group("player")
	anim_tree = $AnimationTree
	collider = $CollisionShape3D
	
	# Configura a junta para começar desativada
	attachment_joint.node_a = NodePath("")
	attachment_joint.node_b = NodePath("")


func _physics_process(delta):

	#=====================================
	# PLAYER BLOQUEADO
	#=====================================

	if controls_locked:
		velocity.x = 0
		velocity.z = 0
		if not is_on_floor():
			velocity.y -= gravity * delta
		move_and_slide()
		return

	#=====================================
	# SISTEMA DE EMPURRAR / PUXAR (TECLA F)
	#=====================================
	
	if Input.is_action_just_pressed("interact"): 
		if not is_pushing and not is_pulling:
			try_grab_box()
		else:
			release_box()

	# Se o jogador se afastar demais ou pular, solta a caixa automaticamente
	if (is_pushing or is_pulling) and Input.is_action_just_pressed("jump"):
		release_box()

	#=====================================
	# DETECÇÃO DE ESCADA OU MURO (TECLA E) - DIAGNÓSTICO ATIVADO
	#=====================================
	var touching_escada = false
	var touching_muro = false

	if wall_check:
		if wall_check.is_colliding():
			var wall = wall_check.get_collider()
			if wall != null:
				# Imprime o diagnóstico detalhado quando o jogador pressiona o botão de ação
				if Input.is_action_just_pressed("climb_action"):
					print("🔍 [TESTE FÍSICO] RayCast colidiu com: ", wall.name)
					print("   - Grupos atribuídos a esse objeto: ", wall.get_groups())
					print("   - Estados de Empurrar/Puxar ativos? Pushing: ", is_pushing, " | Pulling: ", is_pulling)
				
				if not is_pushing and not is_pulling:
					if wall.is_in_group("escada"):
						touching_escada = true
					elif wall.is_in_group("muro"):
						touching_muro = true
		else:
			# Indica que o raio físico não alcançou o obstáculo
			if Input.is_action_just_pressed("climb_action") and not is_wall_climbing and not is_wall_vaulting:
				print("❌ [TESTE FÍSICO] Tecla E pressionada, mas o RayCast3D (WallCheck) não colidiu com nenhum objeto.")
	else:
		if Input.is_action_just_pressed("climb_action"):
			print("🚨 [ERRO CRÍTICO] O nó de RayCast3D 'WallCheck' não foi encontrado ou está nulo!")

	# Exibe informações no console para transições normais de proximidade
	var is_touching_now = touching_escada or touching_muro
	if is_touching_now and not _was_touching_wall:
		print("👉 Objeto interativo detectado! (Escada: ", touching_escada, " | Muro: ", touching_muro, "). Pressione E para interagir.")
		_was_touching_wall = true
	elif not is_touching_now and _was_touching_wall:
		print("👈 Se afastou do objeto.")
		_was_touching_wall = false

	# Clique da tecla E (Execução de ações)
	if Input.is_action_just_pressed("climb_action") and not is_wall_vaulting:
		if touching_escada:
			print("🎬 Iniciando estado de escalada (Escada)...")
			if not is_wall_climbing:
				start_wall_climb()
			else:
				stop_wall_climb()
				
		elif touching_muro and not is_wall_climbing and is_on_floor():
			print("🎬 Iniciando pulo do muro (Vault)...")
			start_wall_vault()
			
		elif is_wall_climbing:
			stop_wall_climb()

	#=====================================
	# COMPORTAMENTO DENTRO DA ESCALADA
	#=====================================
	if is_wall_climbing:
		# LÓGICA DE FIM DA ESCADA: Se atingir o topo subindo
		if reached_wall_top() and Input.is_action_pressed("move_forward"):
			stop_wall_climb()
			
			# Ativa a condição que vai disparar a animação "Mov_Extra_escalar_topo"
			anim_tree.set("parameters/conditions/reached_top", true)
			
			# Bloqueia o controle por um instante até a animação de topo terminar
			lock_controls_for(1.5, "topo_escada") 
			
			# Dá um pequeno empurrão para a frente para o personagem pisar no chão firme do topo
			var forward_vector = -global_transform.basis.z
			global_position += forward_vector * 1.0 + Vector3(0, 0.5, 0)
			return

		# Se ele se afastar completamente da parede física por baixo e ficar parado, solta
		if wall_check and not wall_check.is_colliding() and velocity.y == 0:
			stop_wall_climb()
			return

		var wall_normal = Vector3.ZERO
		if wall_check and wall_check.is_colliding():
			wall_normal = wall_check.get_collision_normal()
			visual.rotation.y = lerp_angle(visual.rotation.y, atan2(wall_normal.x, wall_normal.z), 12.0 * delta)

		# Trava completamente a física horizontal (X e Z)
		velocity.x = 0
		velocity.z = 0
		velocity.y = 0

		# Controles verticais de subida e descida
		if Input.is_action_pressed("move_forward"):
			velocity.y = climb_speed
		elif Input.is_action_pressed("move_back"):
			velocity.y = -climb_speed

		# Se pular, ele se solta se empurrando para trás
		if Input.is_action_just_pressed("jump") and wall_check and wall_check.is_colliding():
			velocity = wall_normal * 4.0
			velocity.y = 3.5
			stop_wall_climb()

		move_and_slide()

		# Configuração da animação (BlendSpace1D do Escada)
		var climb_blend := 0.0
		if velocity.y > 0:
			climb_blend = 1.0  
		elif velocity.y < 0:
			climb_blend = -1.0 
		else:
			climb_blend = 0.0  

		# Força o reset do topo caso ele esteja apenas subindo normalmente
		anim_tree.set("parameters/conditions/reached_top", false)
		anim_tree.set("parameters/Escada/blend_position", climb_blend)
		return # Interrompe o resto da física normal enquanto escala

	#=====================================
	# INPUT NORMAL (FORA DE ESCALADAS/MUROS)
	#=====================================

	var input_dir = Vector2.ZERO
	input_dir.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_dir.y = Input.get_action_strength("move_back") - Input.get_action_strength("move_forward")
	input_dir = input_dir.normalized()

	var direction = Vector3(input_dir.x, 0, input_dir.y)

	#=====================================
	# INPUTS MODIFICADORES
	#=====================================

	is_running = Input.is_action_pressed("run")
	is_crouching = Input.is_action_pressed("crouch")

	#=====================================
	# VELOCIDADE
	#=====================================

	var current_speed = speed

	# Não deixa correr enquanto empurra ou puxa objetos pesados
	if is_pushing or is_pulling:
		current_speed = speed * 0.5 
	else:
		if is_running:
			if mud_multiplier < 1.0:
				current_speed = run_speed * 0.4
			else:
				current_speed = run_speed
		if is_crouching:
			current_speed = crouch_speed

	current_speed *= mud_multiplier

	velocity.x = direction.x * current_speed
	velocity.z = direction.z * current_speed

	#=====================================
	# LÓGICA DE DIREÇÃO (Push vs Pull)
	#=====================================
	if current_box != null:
		var dir_to_box = (current_box.global_position - global_position).normalized()
		dir_to_box.y = 0
		
		if direction.length() > 0:
			var movement_dot = direction.dot(dir_to_box)
			
			if movement_dot > 0.05:
				is_pushing = true
				is_pulling = false
			elif movement_dot < -0.05:
				is_pushing = false
				is_pulling = true
		else:
			pass
	else:
		is_pushing = false
		is_pulling = false

	#=====================================
	# GRAVIDADE
	#=====================================

	if not is_on_floor():
		velocity.y -= gravity * delta

	#=====================================
	# PULO
	#=====================================

	if Input.is_action_just_pressed("jump") and is_on_floor() and not is_crouching and not is_pushing and not is_pulling:
		velocity.y = jump_force
		is_jumping = true
		jump_delay_timer = 0.1

	move_and_slide()

	#=====================================
	# LIMITA PROFUNDIDADE
	#=====================================

	global_position.z = clamp(global_position.z, -3.0, 3.0)

	#=====================================
	# ROTAÇÃO VISUAL E DOS RAYCASTS (OPÇÃO B APLICADA)
	#=====================================

	if direction.length() > 0 and not is_pushing and not is_pulling:
		var target_rotation = atan2(direction.x, direction.z)
		visual.rotation.y = lerp_angle(visual.rotation.y, target_rotation, 10.0 * delta)
		
		# Força TODOS os sensores a rotacionarem junto com o rumo do personagem
		if interaction_ray:
			interaction_ray.rotation.y = target_rotation
		if wall_check:
			wall_check.rotation.y = target_rotation
		if top_check:
			top_check.rotation.y = target_rotation

	#=====================================
	# COLLIDER
	#=====================================

	if collider and collider.shape is CapsuleShape3D:
		if is_crouching:
			collider.shape.height = 1.0
		else:
			collider.shape.height = 2.0

	#=====================================
	# TIMER DO PULO
	#=====================================

	if jump_delay_timer > 0.0:
		jump_delay_timer -= delta

	var landed = is_on_floor() and velocity.y <= 0 and jump_delay_timer <= 0.0
	if landed:
		is_jumping = false
		
	# ==================================================
	# ANIMATION TREE
	# ==================================================

	anim_tree.set("parameters/conditions/is_jumping", is_jumping)
	anim_tree.set("parameters/conditions/is_grounded", landed)
	anim_tree.set("parameters/conditions/is_crouching", is_crouching)
	anim_tree.set("parameters/conditions/is_standing", not is_crouching)
	anim_tree.set("parameters/conditions/is_embarrassed", is_embarrassed)
	anim_tree.set("parameters/conditions/is_not_embarrassed", not is_embarrassed)
	anim_tree.set("parameters/conditions/is_wall_climbing", is_wall_climbing)
	anim_tree.set("parameters/conditions/is_not_wall_climbing", !is_wall_climbing)
	
	# Condições automáticas do Topo da Escada para o AnimationTree
	anim_tree.set("parameters/conditions/reached_top", reached_wall_top() and is_wall_climbing)
	
	# Condições do Muro (Vault) enviados à árvore
	anim_tree.set("parameters/conditions/is_wall_vaulting", is_wall_vaulting)
	anim_tree.set("parameters/conditions/is_not_wall_vaulting", not is_wall_vaulting)
	
	anim_tree.set("parameters/conditions/is_pushing", is_pushing)
	anim_tree.set("parameters/conditions/is_not_pushing", not is_pushing and not is_pulling)
	anim_tree.set("parameters/conditions/is_pulling", is_pulling)
	anim_tree.set("parameters/conditions/is_not_pulling", not is_pushing and not is_pulling)

	# ==================================================
	# BLEND LOCOMOTION & PUSH/PULL
	# ==================================================

	var blend_value = 0.0
	if direction.length() > 0:
		blend_value = current_speed / run_speed

	anim_tree.set("parameters/Locomotion/blend_position", blend_value)
	
	if is_pushing or is_pulling:
		var push_blend = 1.0 if direction.length() > 0 else 0.0
		anim_tree.set("parameters/Push/blend_position", push_blend)
		anim_tree.set("parameters/Pull/blend_position", push_blend)

	# ==================================================
	# BLEND CROUCH & JUMP
	# ==================================================

	var crouch_blend = 1.0 if (is_crouching and direction.length() > 0) else 0.0
	anim_tree.set("parameters/Crouch/blend_position", crouch_blend)
	anim_tree.set("parameters/Jump/blend_position", blend_value)


# ==================================================
# SISTEMA DE EMPURRAR / PUXAR
# ==================================================

func try_grab_box():
	if interaction_ray and interaction_ray.is_colliding():
		var target = interaction_ray.get_collider()
		if target is RigidBody3D and target.is_in_group("pushable"):
			current_box = target
			
			var dir_to_box = current_box.global_position - global_position
			dir_to_box.y = 0 
			if dir_to_box.length() > 0:
				var target_angle = atan2(dir_to_box.x, dir_to_box.z)
				visual.rotation.y = target_angle
				interaction_ray.rotation.y = target_angle
				if wall_check: wall_check.rotation.y = target_angle
				if top_check: top_check.rotation.y = target_angle
			
			is_pushing = true
			
			attachment_joint.node_a = get_path()
			attachment_joint.node_b = current_box.get_path()
			print("📦 Caixa agarrada! Empurrando...")


func release_box():
	if current_box:
		attachment_joint.node_a = NodePath("")
		attachment_joint.node_b = NodePath("")
		current_box = null
	is_pushing = false
	is_pulling = false
	print("📦 Caixa solta.")


# ==================================================
# SISTEMA DE PULAR MURO (PARKOUR / VAULT) - REVISADO
# ==================================================

func start_wall_vault():
	is_wall_vaulting = true
	lock_controls("muro") # Trava os comandos para a animação ditar o ritmo
	
	# Força a Animation Tree a atualizar a condição imediatamente
	anim_tree.set("parameters/conditions/is_wall_vaulting", true)
	anim_tree.set("parameters/conditions/is_not_wall_vaulting", false)
	
	# Desliga o impacto da gravidade zerando a velocidade vertical no início
	velocity = Vector3.ZERO 
	
	# 1. Fase de Subida: Dá um impulso para subir a cerca
	velocity.y = 4.0
	var forward_vector = -global_transform.basis.z
	velocity += forward_vector * 2.0 # Empurra levemente para a frente enquanto sobe
	move_and_slide()
	
	# Espera metade da animação (o tempo de chegar no topo)
	await get_tree().create_timer(0.6).timeout
	
	# 2. Fase de Transpassar: Joga o corpo para cima da plataforma do muro
	global_position += forward_vector * 1.2 + Vector3(0, 0.5, 0)
	
	# Espera o resto da animação terminar de cair/pousar no chão firme
	await get_tree().create_timer(0.6).timeout
	
	stop_wall_vault()


func stop_wall_vault():
	is_wall_vaulting = false
	anim_tree.set("parameters/conditions/is_wall_vaulting", false)
	anim_tree.set("parameters/conditions/is_not_wall_vaulting", true)
	unlock_controls()

# ==================================================
# SISTEMA DE CONTROLE EXTERNO
# ==================================================

func lock_controls(source: String = ""):
	controls_locked = true
	lock_source = source
	velocity = Vector3.ZERO
	is_running = false
	is_crouching = false
	is_jumping = false
	is_wall_climbing = false
	is_wall_vaulting = false
	release_box()


func unlock_controls():
	controls_locked = false
	lock_source = ""


func is_controls_locked() -> bool:
	return controls_locked


func lock_controls_for(seconds: float, source: String = ""):
	lock_controls(source)
	await get_tree().create_timer(seconds).timeout
	if lock_source == source:
		unlock_controls()


# ==================================================
# SISTEMA DE BRONCA
# ==================================================

func start_embarrassed(guard: Node3D):
	lock_controls("guard")
	is_embarrassed = true
	is_running = false
	is_crouching = false
	is_jumping = false
	is_wall_climbing = false
	face_target(guard)


func stop_embarrassed():
	is_embarrassed = false
	unlock_controls()


# ==================================================
# WALL CLIMB AUXILIARES
# ==================================================

func start_wall_climb():
	is_wall_climbing = true
	velocity = Vector3.ZERO


func stop_wall_climb():
	is_wall_climbing = false
	velocity = Vector3.ZERO


func is_on_climbable_wall() -> bool:
	if !wall_check or !wall_check.is_colliding():
		return false

	var wall = wall_check.get_collider()
	if wall == null:
		return false

	return wall.is_in_group("escada") or wall.is_in_group("muro")


func reached_wall_top() -> bool:
	if !top_check or !wall_check:
		return false
	if top_check.is_colliding():
		return false
	return wall_check.is_colliding()


# ==================================================
# UTILIDADES
# ==================================================

func face_target(target: Node3D):
	var direction = target.global_position - global_position
	direction.y = 0

	if direction.length() == 0:
		return

	visual.rotation.y = atan2(direction.x, direction.z)
