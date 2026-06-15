extends CharacterBody3D

# =========================
# CONFIGURAÇÕES
# =========================

@export var speed: float = 2.0

@export var punishment_seconds: float = 30.0
@export var talk_duration: float = 5.0
@export var cooldown_after_detection: float = 60.0

@export var point_a: Marker3D
@export var point_b: Marker3D

@export var detection_area: Area3D
@export var animation_tree: AnimationTree

# =========================
# ESTADOS
# =========================

var current_target: Marker3D
var can_detect := true
var is_talking := false

const ARRIVAL_DISTANCE := 0.5

var current_player: Node3D


func _ready():

	if point_a == null:
		push_error("Guard: Point A não foi atribuído.")
		set_physics_process(false)
		return

	if point_b == null:
		push_error("Guard: Point B não foi atribuído.")
		set_physics_process(false)
		return

	if detection_area == null:
		push_error("Guard: Detection Area não foi atribuída.")
		set_physics_process(false)
		return

	if animation_tree == null:
		push_error("Guard: AnimationTree não foi atribuída.")
		set_physics_process(false)
		return

	current_target = point_b

	detection_area.body_entered.connect(_on_body_entered)

	animation_tree.active = true
	animation_tree["parameters/playback"].travel("Walk")


func _physics_process(delta):

	if is_talking:
		velocity = Vector3.ZERO
		move_and_slide()
		return

	patrol(delta)


# =========================
# PATRULHA
# =========================

func patrol(delta):

	var direction = current_target.global_position - global_position
	direction.y = 0

	if direction.length() <= ARRIVAL_DISTANCE:

		velocity = Vector3.ZERO

		if current_target == point_a:
			current_target = point_b
		else:
			current_target = point_a

		return

	direction = direction.normalized()

	velocity.x = direction.x * speed
	velocity.z = direction.z * speed

	var target_rotation = atan2(direction.x, direction.z)

	rotation.y = lerp_angle(rotation.y, target_rotation, 5.0 * delta)

	move_and_slide()


# =========================
# DETECÇÃO
# =========================

func _on_body_entered(body):

	if not can_detect:
		return

	if is_talking:
		return

	if not body.is_in_group("player"):
		return

	current_player = body
	punish_player(body)


# =========================
# PUNIÇÃO / INTERAÇÃO
# =========================

func punish_player(player):

	can_detect = false
	is_talking = true

	# PARA COMPLETAMENTE
	velocity = Vector3.ZERO
	move_and_slide()

	# garante que não existe movimento residual
	velocity = Vector3.ZERO

	animation_tree["parameters/playback"].travel("Talk")

	current_player = player

	# ativa estado no player
	if player.has_method("start_embarrassed"):
		player.start_embarrassed(self)

	# espera 1 frame antes de rotacionar (evita snap/teleporte visual)
	await get_tree().process_frame

	face_player(player)

	await get_tree().create_timer(talk_duration).timeout

	GameTimer.remove_time(punishment_seconds)

	if player.has_method("stop_embarrassed"):
		player.stop_embarrassed()

	is_talking = false

	animation_tree["parameters/playback"].travel("Walk")

	start_detection_cooldown()


# =========================
# OLHAR PARA O PLAYER (SEM TELEPORTE VISUAL)
# =========================

func face_player(player):

	var dir = player.global_position - global_position
	dir.y = 0

	if dir.length() == 0:
		return

	rotation.y = atan2(dir.x, dir.z)


# =========================
# COOLDOWN
# =========================

func start_detection_cooldown():

	await get_tree().create_timer(cooldown_after_detection).timeout

	can_detect = true

	print("Guarda pronto para detectar novamente.")
