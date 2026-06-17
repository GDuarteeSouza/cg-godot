extends CharacterBody3D

@export var speed_walk := 2.0
@export var speed_run := 5.0
@export var gravity := 14.0

# Tempo perdido ao ser pego pelo cachorro
@export var punishment_seconds := 60.0

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

	# Gravidade
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0

	match current_state:

		State.IDLE:

			velocity.x = 0
			velocity.z = 0

			update_animation_state("idle")

		State.CHASING:

			if player and agent:

				agent.target_position = player.global_position

				var next_position = agent.get_next_path_position()

				var direction = next_position - global_position
				direction.y = 0

				if direction.length() > 0.1:

					direction = direction.normalized()

					velocity.x = direction.x * speed_run
					velocity.z = direction.z * speed_run

					update_animation_state("run")

					# Rotaciona para a direção do caminho
					var target_rotation = atan2(
						direction.x,
						direction.z
					)

					visual.rotation.y = lerp_angle(
						visual.rotation.y,
						target_rotation,
						12.0 * delta
					)

				else:

					velocity.x = 0
					velocity.z = 0

		State.ATTACKING:

			velocity.x = 0
			velocity.z = 0

			update_animation_state("attacking")

	move_and_slide()


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

		# Remove 1 minuto do cronômetro
		GameTimer.remove_time(punishment_seconds)

		game_over()


func game_over() -> void:

	print("🚨 GAME OVER: O cachorro te pegou!")


func update_animation_state(state_name: String) -> void:

	if not anim_tree:
		return

	anim_tree.set(
		"parameters/conditions/is_idle",
		state_name == "idle"
	)

	anim_tree.set(
		"parameters/conditions/is_walking",
		state_name == "walk"
	)

	anim_tree.set(
		"parameters/conditions/is_running",
		state_name == "run"
	)

	anim_tree.set(
		"parameters/conditions/is_attacking",
		state_name == "attacking"
	)
