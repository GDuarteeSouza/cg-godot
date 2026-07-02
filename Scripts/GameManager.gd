extends Node

@export var starting_time: float = 120.0

var remaining_time: float
var timer_running := false

signal pendrive_collected
var pendrives_collected: int = 0

signal cup_collected
signal cake_collected
var cup_found: bool = false
var cake_found: bool = false

var checkpoint_1_reached: bool = false
var checkpoint_2_reached: bool = false
var checkpoint_3_reached: bool = false
var checkpoint_fase_2_1_reached: bool = false
signal phase_1_completed
signal phase_2_completed
signal computer_accessed

signal show_interaction_message(message: String)
signal hide_interaction_message()

func _ready():
	reset_timer()

func _process(delta):

	if not timer_running:
		return

	if remaining_time <= 0:
		return

	remaining_time -= delta

	if remaining_time <= 0:
		remaining_time = 0
		game_over()

func start_timer():
	timer_running = true

func stop_timer():
	timer_running = false

func reset_timer():
	remaining_time = starting_time
	timer_running = false

func remove_time(seconds: float):
	remaining_time -= seconds

	if remaining_time < 0:
		remaining_time = 0

func add_time(seconds: float):
	remaining_time += seconds

func game_over():
	var main = get_tree().current_scene
	if main.has_method("mostrar_game_over"):
		main.mostrar_game_over()
	else:
		main.get_node("GameWorld").visible = false
		main.get_node("GameOver").visible = true

func game_win():
	timer_running = false
	get_tree().paused = true
	
	var win_layer = CanvasLayer.new()
	win_layer.layer = 200 # Over everything
	win_layer.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(win_layer)
	
	var bg = ColorRect.new()
	bg.color = Color(0, 0, 0, 1)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	win_layer.add_child(bg)
	
	var texture_rect = TextureRect.new()
	texture_rect.texture = load("res://Assets/fase3/rafael/tela-jogo-ganho.png")
	texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	texture_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	win_layer.add_child(texture_rect)

func collect_pendrive():
	pendrives_collected += 1
	pendrive_collected.emit()

func collect_cup():
	cup_found = true
	cup_collected.emit()

func collect_cake():
	cake_found = true
	cake_collected.emit()

func complete_phase_1():
	print("Fase 1 completada com sucesso!")
	phase_1_completed.emit()

var video_layer: CanvasLayer
var video_player: VideoStreamPlayer

func access_computer():
	print("Computador acessado via GameManager!")
	computer_accessed.emit()
	
	if not video_layer:
		video_layer = CanvasLayer.new()
		video_layer.layer = 100
		video_layer.process_mode = Node.PROCESS_MODE_ALWAYS
		add_child(video_layer)
		
		var bg = ColorRect.new()
		bg.color = Color(0, 0, 0, 1)
		bg.set_anchors_preset(Control.PRESET_FULL_RECT)
		video_layer.add_child(bg)
		
		var aspect_container = AspectRatioContainer.new()
		aspect_container.set_anchors_preset(Control.PRESET_FULL_RECT)
		aspect_container.ratio = 1420.0 / 854.0
		aspect_container.stretch_mode = AspectRatioContainer.STRETCH_FIT
		video_layer.add_child(aspect_container)
		
		video_player = VideoStreamPlayer.new()
		video_player.expand = true
		video_player.set_anchors_preset(Control.PRESET_FULL_RECT)
		video_player.finished.connect(_on_video_finished)
		aspect_container.add_child(video_player)
		
		video_player.stream = load("res://Assets/tela-pc.ogv")
		
	video_layer.visible = true
	video_player.play()
	get_tree().paused = true

func _on_video_finished():
	if video_layer:
		video_layer.visible = false
	get_tree().paused = false
	print("Fase 2 completada com sucesso! (Início da Fase 3)")
	phase_2_completed.emit()
	
	# Reseta o timer para 2 minutos (120 segundos) para a Fase 3
	remaining_time = 120.0
	timer_running = true
	
	# Iniciar o desmaio do player
	trigger_faint_transition()

func _find_node_by_name(node: Node, target_name: String) -> Node:
	if node.name == target_name:
		return node
	for child in node.get_children():
		var found = _find_node_by_name(child, target_name)
		if found:
			return found
	return null

func trigger_faint_transition():
	# Carrega a cena de introdução da Fase 3
	var intro_scene = load("res://Scenes/IntroFase3.tscn").instantiate()
	intro_scene.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(intro_scene)
	
	# Pausar o jogo enquanto a intro rola
	get_tree().paused = true

	# Encontra o verdadeiro Player (evitando o NavigationRegion3D que está no grupo errado)
	var player = null
	for node in get_tree().get_nodes_in_group("player"):
		if node.name == "Player" or node is CharacterBody3D:
			player = node
			break
			
	var current_scene = get_tree().current_scene
	var checkpoint = _find_node_by_name(current_scene, "checkpoint-fase-3-1")
	
	print("DEBUG TELEPORTE:")
	print("- Current Scene: ", current_scene.name)
	print("- Player Encontrado: ", player != null, " Path: ", player.get_path() if player else "N/A")
	print("- Checkpoint Encontrado: ", checkpoint != null, " Path: ", checkpoint.get_path() if checkpoint else "N/A")
	
	if player and checkpoint:
		print("- Posicao antiga Player: ", player.global_position)
		print("- Posicao Checkpoint: ", checkpoint.global_position)
		# call_deferred garante que a física do Godot mova o corpo sem conflitos
		player.set_deferred("global_position", checkpoint.global_position)
		# Opcional: zerar a velocidade para evitar que o player "escorregue" ao chegar
		if "velocity" in player:
			player.velocity = Vector3.ZERO
		print("- Comando set_deferred enviado.")
	else:
		if not player:
			print("Aviso: Player não encontrado no grupo 'player' para o teleporte!")
		if not checkpoint:
			print("Aviso: Node 'checkpoint-fase-3-1' não encontrado na cena atual para o teleporte!")

	# Espera a tela de introdução acabar
	await intro_scene.intro_finished
	
	# Despausa o jogo
	get_tree().paused = false
