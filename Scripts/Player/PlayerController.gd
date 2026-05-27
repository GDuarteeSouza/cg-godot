extends CharacterBody3D

@export var speed := 5.0
@export var run_speed := 8.0
@export var crouch_speed := 2.0
@export var jump_force := 4.5
@export var gravity := 9.8

var anim_tree
var collider

@onready var visual = $Skeleton3D

var is_crouching = false
var is_running = false
var is_jumping = false

var jump_delay_timer := 0.0

func _ready():

	anim_tree = $AnimationTree
	collider = $CollisionShape3D

func _physics_process(delta):

	var input_dir = Vector2.ZERO

	# MOVIMENTO
	input_dir.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")

	input_dir.y = Input.get_action_strength("move_back") - Input.get_action_strength("move_forward")

	input_dir = input_dir.normalized()

	var direction = Vector3(
		input_dir.x,
		0,
		input_dir.y
	)

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

	# LIMITA PROFUNDIDADE
	global_position.z = clamp(global_position.z, -3.0, 3.0)

	# -------------------------
	# ROTAÇÃO VISUAL REAL
	# -------------------------

	if direction.length() > 0:

		# CALCULA ÂNGULO BASEADO NO MOVIMENTO
		var target_rotation = atan2(direction.x, direction.z)

		# SUAVIZA ROTAÇÃO
		visual.rotation.y = lerp_angle(
			visual.rotation.y,
			target_rotation,
			10.0 * delta
		)

	# -------------------------
	# COLLIDER
	# -------------------------

	var shape = collider.shape

	if shape is CapsuleShape3D:

		if is_crouching:
			shape.height = 1.0
		else:
			shape.height = 2.0

	# -------------------------
	# TIMER PULO
	# -------------------------

	if jump_delay_timer > 0.0:
		jump_delay_timer -= delta

	var landed = is_on_floor() and velocity.y <= 0 and jump_delay_timer <= 0.0

	if landed:
		is_jumping = false

	# -------------------------
	# ANIMATION TREE
	# -------------------------

	anim_tree.set("parameters/conditions/is_jumping", is_jumping)

	anim_tree.set("parameters/conditions/is_grounded", landed)

	anim_tree.set("parameters/conditions/is_crouching", is_crouching)

	anim_tree.set("parameters/conditions/is_standing", not is_crouching)

	# BLEND LOCOMOTION
	var blend_value = 0.0

	if direction.length() > 0:
		blend_value = current_speed / run_speed

	anim_tree.set("parameters/Locomotion/blend_position", blend_value)

	# BLEND CROUCH
	var crouch_blend = 1.0 if (is_crouching and direction.length() > 0) else 0.0

	anim_tree.set("parameters/Crouch/blend_position", crouch_blend)

	# BLEND JUMP
	anim_tree.set("parameters/Jump/blend_position", blend_value)
