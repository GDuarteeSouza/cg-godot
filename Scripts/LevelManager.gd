extends Node

@onready var checkpoint_x = $"CheckpointX"
@onready var checkpoint_y = $"CheckpointY"

var passou_em_x := false
var mapa_concluido := false

func _ready():

	checkpoint_x.body_entered.connect(_on_checkpoint_x_body_entered)
	checkpoint_y.body_entered.connect(_on_checkpoint_y_body_entered)

func _on_checkpoint_x_body_entered(body):

	if body.name != "Player":
		return

	if passou_em_x:
		return

	passou_em_x = true

	print("Checkpoint X atingido!")
	print("Novo objetivo: Vá para o ponto Y")

func _on_checkpoint_y_body_entered(body):

	if body.name != "Player":
		return

	if mapa_concluido:
		return

	if not passou_em_x:
		print("Você precisa passar pelo ponto X primeiro!")
		return

	mapa_concluido = true

	print("MAPA CONCLUÍDO!")

	vitoria()

func vitoria():

	print("VOCÊ VENCEU O MAPA!")

	# Exemplo:
	# get_tree().change_scene_to_file("res://Mapa2.tscn")
