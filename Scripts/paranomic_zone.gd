extends Area3D

@export var camera_controller: Node3D

# =========================
# AJUSTES DA ZONA
# =========================

@export var camera_offset := Vector3(
	0,
	5,
	18
)

func _ready():

	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body):

	if not body.is_in_group("player"):
		return

	if camera_controller == null:
		return

	camera_controller.set_camera_offset(
		camera_offset
	)


func _on_body_exited(body):

	if not body.is_in_group("player"):
		return

	if camera_controller == null:
		return

	camera_controller.reset_camera()
