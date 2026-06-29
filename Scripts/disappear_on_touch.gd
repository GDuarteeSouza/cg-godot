extends Area3D

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D):
	if body.name == "Player":
		if name == "cup3d" and GameManager.has_method("collect_cup"):
			GameManager.collect_cup()
		elif name == "cake3d" and GameManager.has_method("collect_cake"):
			GameManager.collect_cake()
		queue_free()
