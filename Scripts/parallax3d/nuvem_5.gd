extends MeshInstance3D

@export var velocidade : float = 5.0

func _process(delta):
	var direcao = Vector3.ZERO

	# Lendo as setas do teclado ou letras diretamente
	if Input.is_key_pressed(KEY_RIGHT) or Input.is_key_pressed(KEY_D):
		direcao.x -= 1
	if Input.is_key_pressed(KEY_LEFT) or Input.is_key_pressed(KEY_A):
		direcao.x += 1
	if Input.is_key_pressed(KEY_DOWN) or Input.is_key_pressed(KEY_S):
		direcao.z += 1
	if Input.is_key_pressed(KEY_UP) or Input.is_key_pressed(KEY_W):
		direcao.z -= 1

	if direcao.length() > 0:
		direcao = direcao.normalized()

	translate(direcao * velocidade * delta)
