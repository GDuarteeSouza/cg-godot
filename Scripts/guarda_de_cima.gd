extends Node3D

@export var punishment_seconds := 30.0
@export var lock_time := 5.0

@onready var detection_area = $Area3D

var can_detect := true


func _ready():
	detection_area.body_entered.connect(_on_body_entered)


func _on_body_entered(body):

	if not can_detect:
		return

	if not body.is_in_group("player"):
		return

	can_detect = false

	# trava o player
	body.lock_controls("npc")

	# espera alguns segundos
	await get_tree().create_timer(lock_time).timeout

	# tira tempo do cronômetro
	GameTimer.remove_time(punishment_seconds)

	# libera o player
	body.unlock_controls()

	# evita detectar novamente imediatamente
	await get_tree().create_timer(1.0).timeout

	can_detect = true
