extends CharacterBody3D

@export var speed := 4.0
@export var gravity := 9.8

var player = null
var chasing = false

@onready var agent = $NavigationAgent3D

@onready var detection_area = $DetectionArea

@onready var visual = $"DogModel/Sketchfab_model/root/GLTF_SceneRootNode/rig-root_47/GLTF_created_0/dog_46"

func _ready():

	detection_area.body_entered.connect(_on_body_entered)

	detection_area.body_exited.connect(_on_body_exited)

func _physics_process(delta):

	# GRAVIDADE
	if not is_on_floor():
		velocity.y -= gravity * delta

	# PERSEGUIÇÃO
	if chasing and player != null:

		agent.target_position = player.global_position

		var next_position = agent.get_next_path_position()

		var direction = (
			next_position - global_position
		).normalized()

		velocity.x = direction.x * speed
		velocity.z = direction.z * speed

		# ROTAÇÃO
		if direction.length() > 0:

			var target_rotation = atan2(
				direction.x,
				direction.z
			)

			visual.rotation.y = lerp_angle(
				visual.rotation.y,
				target_rotation,
				10.0 * delta
			)

	else:

		velocity.x = 0
		velocity.z = 0

	move_and_slide()

	# GAME OVER
	if player != null:

		if global_position.distance_to(player.global_position) < 1.5:

			game_over()

func _on_body_entered(body):

	if body.is_in_group("player"):

		player = body
		chasing = true

func _on_body_exited(body):

	if body == player:

		player = null
		chasing = false

func game_over():

	print("GAME OVER")
