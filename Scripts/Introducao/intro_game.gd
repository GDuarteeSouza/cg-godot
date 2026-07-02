extends CanvasLayer

signal intro_finished

@onready var center_bg = $CenterBg
@onready var vbox = $ScrollContainer/VBoxContainer
@onready var scroll = $ScrollContainer
@onready var prompt_label = $PromptLabel

var current_step = 0
var steps = [
	{
		"sender": "Eduardo",
		"text": "Eduardo: Cara, eu não deveria ter faltado a tantas aulas... Agora sou obrigado a assistir sozinho a última aula do semestre...",
		"bg": Color(0.95, 0.75, 0.3),
		"is_thought": true
	},
	{
		"sender": "Professor D.",
		"text": "Professor D.: E com isso, Eduardo, estamos quase finalizando a matéria. Faltam só 5 slides e libero você.",
		"bg": Color(0.95, 0.75, 0.3),
		"is_thought": false
	},
	{
		"sender": "Professor D.",
		"text": "Professor D.: ... É. Parece que a energia acabou na faculdade. Ainda bem que tenho uma lanterna e matéria que falta na cabeça! Vamos continuar com a aula!",
		"bg": Color(0.08, 0.1, 0.2),
		"is_thought": false
	},
	{
		"sender": "Eduardo",
		"text": "Eduardo: Não é possível! Nem com a faculdade no escuro ele vai liberar? Vou precisar de um café pra aguentar isso...",
		"bg": Color(0.08, 0.1, 0.2),
		"is_thought": true
	},
	{
		"sender": "Eduardo",
		"text": "Eduardo: Preciso ser rápido para voltar para chamada.",
		"bg": Color(0.08, 0.1, 0.2),
		"is_thought": true
	},

]

func _ready():
	center_bg.color = steps[0]["bg"]
	mostrar_passo(0)

func _input(event):
	if event.is_action_pressed("interact") or event.is_action_pressed("ui_accept") or (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		# Consome o input para evitar que ative outras coisas
		get_viewport().set_input_as_handled()
		avancar()

func avancar():
	current_step += 1
	if current_step >= steps.size():
		intro_finished.emit()
		queue_free()
		return
	
	# Transição suave de cor do fundo central
	var next_bg = steps[current_step]["bg"]
	var tween = create_tween()
	tween.tween_property(center_bg, "color", next_bg, 0.5)
	
	mostrar_passo(current_step)

func mostrar_passo(idx: int):
	var step = steps[idx]
	var balao = criar_balao(step["sender"], step["text"], step["is_thought"])
	vbox.add_child(balao)
	
	# Scroll automático para o fundo
	await get_tree().process_frame
	scroll.scroll_vertical = int(vbox.size.y)

func criar_balao(sender: String, text: String, is_thought: bool = false) -> Control:
	var container = VBoxContainer.new()
	container.add_theme_constant_override("separation", 0)
	
	var panel = PanelContainer.new()
	var label = RichTextLabel.new()
	label.bbcode_enabled = true
	label.fit_content = true
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.custom_minimum_size = Vector2(400, 0)
	
	if is_thought:
		label.text = "[i]" + text + "[/i]"
	else:
		label.text = text
	
	# Configuração de fonte
	label.add_theme_font_size_override("normal_font_size", 18)
	label.add_theme_font_size_override("italics_font_size", 18)
	
	panel.add_child(label)
	
	var style = StyleBoxFlat.new()
	style.content_margin_left = 20
	style.content_margin_right = 20
	style.content_margin_top = 15
	style.content_margin_bottom = 15
	
	if is_thought:
		style.corner_radius_top_left = 30
		style.corner_radius_top_right = 30
		style.corner_radius_bottom_left = 30
		style.corner_radius_bottom_right = 30
	else:
		style.corner_radius_top_left = 15
		style.corner_radius_top_right = 15
		style.corner_radius_bottom_left = 15
		style.corner_radius_bottom_right = 15
	
	if sender == "Eduardo":
		style.bg_color = Color(0.18, 0.24, 0.35, 0.9)
		container.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
		label.add_theme_color_override("default_color", Color.WHITE)
	else:
		style.bg_color = Color(0.9, 0.9, 0.9, 0.9)
		container.size_flags_horizontal = Control.SIZE_SHRINK_END
		label.add_theme_color_override("default_color", Color.BLACK)
		
	panel.add_theme_stylebox_override("panel", style)
	container.add_child(panel)
	
	# Adiciona as bolinhas de pensamento
	if is_thought:
		var tail = Control.new()
		tail.custom_minimum_size = Vector2(0, 25)
		
		var circle1 = Panel.new()
		var c1_style = StyleBoxFlat.new()
		c1_style.bg_color = style.bg_color
		c1_style.corner_radius_top_left = 20
		c1_style.corner_radius_top_right = 20
		c1_style.corner_radius_bottom_left = 20
		c1_style.corner_radius_bottom_right = 20
		circle1.add_theme_stylebox_override("panel", c1_style)
		circle1.size = Vector2(16, 16)
		
		var circle2 = Panel.new()
		var c2_style = c1_style.duplicate()
		circle2.add_theme_stylebox_override("panel", c2_style)
		circle2.size = Vector2(8, 8)
		
		if sender == "Eduardo":
			circle1.position = Vector2(40, -5)
			circle2.position = Vector2(25, 12)
		else:
			circle1.position = Vector2(380, -5)
			circle2.position = Vector2(400, 12)
			
		tail.add_child(circle1)
		tail.add_child(circle2)
		container.add_child(tail)
	
	return container
