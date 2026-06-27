extends CanvasLayer

@onready var sleep_bar = $SleepBar
@onready var sleep = get_tree().get_first_node_in_group("sleep_manager")

func _ready():
	sleep.sleep_changed.connect(_on_sleep_changed)

func _on_sleep_changed(value):
	sleep_bar.value = value
