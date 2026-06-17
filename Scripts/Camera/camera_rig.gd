extends Node3D

@export var target: Node3D

@export var normal_offset := Vector3(0, 3, 12)

@export var follow_speed := 5.0
@export var transition_speed := 2.0

var target_offset: Vector3
var current_offset: Vector3


func _ready():

	if target == null:

		var players = get_tree().get_nodes_in_group("player")

		if players.size() > 0:
			target = players[0]

	target_offset = normal_offset
	current_offset = normal_offset


func _process(delta):

	if target == null:
		return

	current_offset = current_offset.lerp(
		target_offset,
		transition_speed * delta
	)

	var desired_position = global_position

	desired_position.x = target.global_position.x + current_offset.x
	desired_position.y = target.global_position.y + current_offset.y
	desired_position.z = current_offset.z

	global_position = global_position.lerp(
		desired_position,
		follow_speed * delta
	)


func set_camera_offset(new_offset: Vector3):

	target_offset = new_offset


func reset_camera():

	target_offset = normal_offset
