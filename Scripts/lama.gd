extends Area3D

@export var walk_penalty := 0.6 # Reduz a velocidade normal para 60%
@export var normal_speed := 1.0

func _ready():
	# Conecta os sinais de entrada e saída do corpo automaticamente
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node):
	# Verifica se quem entrou na lama foi o Player
	if body.is_in_group("player") and "mud_multiplier" in body:
		body.mud_multiplier = walk_penalty
		print("💩 Player entrou na lama! Velocidade reduzida.")


func _on_body_exited(body: Node):
	# Devolve a velocidade normal quando o Player sai da lama
	if body.is_in_group("player") and "mud_multiplier" in body:
		body.mud_multiplier = normal_speed
		print("✨ Player saiu da lama! Velocidade restaurada.")
