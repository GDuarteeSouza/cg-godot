extends CharacterBody3D

@export var speed: float = 2.0
@export var punishment_seconds: float = 10.0
@export var cooldown_after_detection: float = 60.0

@onready var point_a: Marker3D = $PointA
@onready var point_b: Marker3D = $PointB
@onready var detection_area: Area3D = $DetectionArea

var current_target: Marker3D
var can_detect: bool = true


func _ready():
	current_target = point_b

	detection_area.body_entered.connect(_on_body_entered)


func _physics_process(_delta):
	patrol()


func patrol():
	var direction = current_target.global_position - global_position
	direction.y = 0

	# Chegou ao ponto atual
	if direction.length() < 0.2:
		if current_target == point_a:
			current_target = point_b
		else:
			current_target = point_a

		velocity = Vector3.ZERO
		return

	direction = direction.normalized()

	velocity.x = direction.x * speed
	velocity.z = direction.z * speed

	look_at(
		Vector3(
			current_target.global_position.x,
			global_position.y,
			current_target.global_position.z
		),
		Vector3.UP
	)

	move_and_slide()


func _on_body_entered(body):
	if not can_detect:
		return

	if not body.is_in_group("player"):
		return

	punish_player()


func punish_player():
	can_detect = false

	GameTimer.remove_time(punishment_seconds)

	print("Player flagrado!")
	print("Tempo perdido: ", punishment_seconds, " segundos.")

	start_detection_cooldown()


func start_detection_cooldown():
	await get_tree().create_timer(cooldown_after_detection).timeout

	can_detect = true

	print("Guarda pode detectar novamente.")
