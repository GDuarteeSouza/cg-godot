extends Node3D

@export var min_event_interval := 2.0
@export var max_event_interval := 5.0

@export var min_lights_per_event := 1
@export var max_lights_per_event := 3

@export var min_flickers := 3
@export var max_flickers := 5

@export var min_flicker_delay := 0.03
@export var max_flicker_delay := 0.12

@export var energy_variation := 0.3

var lights: Array[Light3D] = []
var default_energy := {}


func _ready():

	collect_lights()

	if lights.is_empty():
		push_error("Nenhuma Light3D encontrada!")
		return

	event_loop()


func collect_lights():

	lights.clear()
	default_energy.clear()

	collect_recursive(self)


func collect_recursive(node: Node):

	for child in node.get_children():

		if child is Light3D:

			lights.append(child)
			default_energy[child] = child.light_energy

		collect_recursive(child)


func event_loop():

	while true:

		await get_tree().create_timer(
			randf_range(
				min_event_interval,
				max_event_interval
			)
		).timeout

		await flicker_random_group()


func flicker_random_group():

	var amount := randi_range(
		min_lights_per_event,
		min(max_lights_per_event, lights.size())
	)

	var selected := []

	while selected.size() < amount:

		var lamp = lights.pick_random()

		if not selected.has(lamp):
			selected.append(lamp)

	var repetitions := randi_range(
		min_flickers,
		max_flickers
	)

	for i in range(repetitions):

		for lamp in selected:
			lamp.visible = false

		await get_tree().create_timer(
			randf_range(
				min_flicker_delay,
				max_flicker_delay
			)
		).timeout

		for lamp in selected:

			lamp.visible = true

			lamp.light_energy = default_energy[lamp] * randf_range(
				1.0 - energy_variation,
				1.0
			)

		await get_tree().create_timer(
			randf_range(
				min_flicker_delay,
				max_flicker_delay
			)
		).timeout

	for lamp in selected:

		lamp.visible = true
		lamp.light_energy = default_energy[lamp]
