extends Area3D

const Rotation_speed := 45.0

@onready var start_pos := position.y
@onready var end_pos := position.y + 0.5

# Called when the node enters the scene tree for the first time.
func _ready():
	if not GameManager.checkpoint_3_reached:
		hide()
		process_mode = Node.PROCESS_MODE_DISABLED
		GameManager.phase_1_completed.connect(_on_phase_1_completed)
		
	var penDrive_tween := create_tween().set_loops().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	penDrive_tween.tween_property(self,"position:y",end_pos, 1.0).from(start_pos)
	penDrive_tween.tween_property(self,"position:y",start_pos, 1.0).from(end_pos)

func _on_phase_1_completed():
	show()
	process_mode = Node.PROCESS_MODE_INHERIT

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	rotate_y(deg_to_rad(Rotation_speed *delta))


func _on_body_entered(body):
	if body.name == "Player":
		GameManager.collect_pendrive()
		queue_free()
