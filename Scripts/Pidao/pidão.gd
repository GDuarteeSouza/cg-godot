extends CharacterBody3D

@onready var nav_agent = $NavigationAgent3D
@onready var animation_tree = $AnimationTree
@onready var playback = animation_tree["parameters/playback"]

var player = null

var walk_speed = 3.0
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _physics_process(delta):

	if not is_on_floor():
		velocity.y -= gravity * delta

	if player:

		nav_agent.target_position = player.global_position

		var next_position = nav_agent.get_next_path_position()

		var direction = (next_position - global_position).normalized()

		velocity.x = direction.x * walk_speed
		velocity.z = direction.z * walk_speed

		look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z))

		playback.travel("walk")

	else:

		velocity.x = move_toward(velocity.x, 0, walk_speed)
		velocity.z = move_toward(velocity.z, 0, walk_speed)

		playback.travel("idle")

	move_and_slide()


func _on_detection_area_body_entered(body: Node3D) -> void:
	pass # Replace with function body.
