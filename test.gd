extends SceneTree

func _init():
	var packed = load("res://Scenes/FASE_1/MainGame.tscn")
	var scene = packed.instantiate()
	var checkpoint = scene.find_child("checkpoint-fase-3-1", true, false)
	if checkpoint:
		print("CHECKPOINT FOUND: ", checkpoint.get_path())
		print("POSITION: ", checkpoint.global_position)
	else:
		print("CHECKPOINT NOT FOUND")
	
	# Try to find player
	var player = scene.find_child("Player", true, false)
	if player:
		print("PLAYER FOUND: ", player.get_path())
	else:
		print("PLAYER NOT FOUND")
		
	quit()
