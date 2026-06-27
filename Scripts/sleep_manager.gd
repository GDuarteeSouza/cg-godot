extends Node

signal sleep_changed(value)
signal player_fell_asleep

@export var max_sleep: float = 100.0
@export var drain_speed: float = 5.0
@export var recover_speed: float = 15.0

# Tempo que o jogador pode ficar totalmente sem sono
@export var sleep_delay: float = 3.0

var current_sleep: float
var inside_light := false

var sleep_timer := 0.0
var is_sleeping := false

func _ready():
	current_sleep = max_sleep
	emit_signal("sleep_changed", current_sleep)

func _process(delta):

	if is_sleeping:
		return

	# Recupera ou perde sono
	if inside_light:
		current_sleep += recover_speed * delta
		sleep_timer = 0.0
	else:
		current_sleep -= drain_speed * delta

	current_sleep = clamp(current_sleep, 0.0, max_sleep)

	emit_signal("sleep_changed", current_sleep)

	# Contador de desmaio
	if current_sleep <= 0.0:

		sleep_timer += delta

		if sleep_timer >= sleep_delay:
			is_sleeping = true
			emit_signal("player_fell_asleep")

	else:
		sleep_timer = 0.0
