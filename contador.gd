extends Label

func _process(delta):

	text = "Advertências: " + str(GameManager.warnings) + "/3"
