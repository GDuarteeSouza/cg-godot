extends CharacterBody3D

@export var speed := 5.0
@export var run_speed := 8.0
@export var crouch_speed := 2.0
@export var jump_force := 4.5
@export var gravity := 9.8

var anim_tree
var collider

var is_crouching = false
var is_running = false
var is_jumping = false

# Janela de segurança para a física desgrudar do chão no frame inicial
var jump_delay_timer := 0.0

func _ready():
	anim_tree = $AnimationTree
	collider = $CollisionShape3D

func _physics_process(delta):
	var input_dir = Vector2.ZERO

	input_dir.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_dir.y = Input.get_action_strength("move_back") - Input.get_action_strength("move_forward")

	input_dir = input_dir.normalized()
	var direction = Vector3(input_dir.x, 0, input_dir.y)

	# INPUTS
	is_running = Input.is_action_pressed("run")
	is_crouching = Input.is_action_pressed("crouch")

	# VELOCIDADE
	var current_speed = speed

	if is_running:
		current_speed = run_speed
	if is_crouching:
		current_speed = crouch_speed

	velocity.x = direction.x * current_speed
	velocity.z = direction.z * current_speed

	# GRAVIDADE
	if not is_on_floor():
		velocity.y -= gravity * delta

	# PULO
	if Input.is_action_just_pressed("jump") and is_on_floor() and not is_crouching:
		velocity.y = jump_force
		is_jumping = true
		jump_delay_timer = 0.1 

	move_and_slide()

	# ROTAÇÃO
	if direction != Vector3.ZERO:
		look_at(global_transform.origin + direction, Vector3.UP)

	# COLLIDER
	var shape = collider.shape
	if shape is CapsuleShape3D:
		if is_crouching:
			shape.height = 1.0
		else:
			shape.height = 2.0

	# Temporizador de segurança do pulo
	if jump_delay_timer > 0.0:
		jump_delay_timer -= delta

	# Lógica para checar se pousou de verdade (Chão ativo + velocidade nula ou negativa + timer zerado)
	var landed = is_on_floor() and velocity.y <= 0 and jump_delay_timer <= 0.0

	if landed:
		is_jumping = false

	# -------------------------
	# 🎯 ATUALIZA ANIMATION TREE
	# -------------------------

	# 1. Condições de transição dos Estados
	anim_tree.set("parameters/conditions/is_jumping", is_jumping)
	anim_tree.set("parameters/conditions/is_grounded", landed) # Força a volta do pulo se tocou o chão
	anim_tree.set("parameters/conditions/is_crouching", is_crouching)
	anim_tree.set("parameters/conditions/is_standing", not is_crouching)

	# 2. Mistura de Animações nos BlendSpaces (Blends)
	var blend_value = 0.0
	if direction.length() > 0:
		blend_value = current_speed / run_speed

	# Atualiza o Blend do Locomotion (Normal/Corrida)
	anim_tree.set("parameters/Locomotion/blend_position", blend_value)
	
	# Atualiza o Blend do Crouch (Parado/Andando)
	var crouch_blend = 1.0 if (is_crouching and direction.length() > 0) else 0.0
	anim_tree.set("parameters/Crouch/blend_position", crouch_blend)

	# Atualiza o Blend do Jump (Usa a velocidade horizontal atual para decidir qual salto usar)
	# Se pular parado, passa 0. Se pular correndo, passa o valor proporcional da velocidade
	anim_tree.set("parameters/Jump/blend_position", blend_value)
