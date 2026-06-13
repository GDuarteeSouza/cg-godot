extends CanvasLayer

@onready var timer_label: Label = $TimerLabel


func _process(_delta):

	var total_seconds := int(GameTimer.remaining_time)

	var minutes := total_seconds / 60
	var seconds := total_seconds % 60

	timer_label.text = "%02d:%02d" % [
		minutes,
		seconds
	]
