extends Node3D

@export var target: Node3D

@export var follow_speed := 5.0
@export var offset := Vector3(0, 4, 12)

func _process(delta):

	if target == null:
		return

	var desired_position = Vector3(
		target.global_position.x + offset.x,
		offset.y,
		offset.z
	)

	global_position = global_position.lerp(
		desired_position,
		follow_speed * delta
	)

	look_at(
		Vector3(
			target.global_position.x,
			0,
			target.global_position.z
		),
		Vector3.UP
	)
