extends SceneTree

func _init():
	var scene = load("res://Scenes/FASE_1/fase_1_cantina.scn")
	if not scene:
		print("Failed to load scene")
		quit()
		return
	
	var root = scene.instantiate()
	print("Scene root: ", root.name)
	_print_tree(root, "")
	quit()

func _print_tree(node, indent):
	var info = node.name + " (" + node.get_class() + ")"
	if node is StaticBody3D:
		info += " - collision_layer: " + str(node.collision_layer) + ", collision_mask: " + str(node.collision_mask)
	if node is MeshInstance3D:
		var nav = "no_nav"
	print(indent + info)
	for child in node.get_children():
		_print_tree(child, indent + "  ")

