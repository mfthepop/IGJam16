extends Node


@export_category("Level")
@export_file("*.tscn") var next_scene: String

@export_category("Countdowns")
@export var next_level_countdown: float = 3.0
@export var restart_countdown: float = 30.0


var countdown_active: bool = false
var remaining_time: float = 0.0

var level_finished: bool = false
var game_started: bool = false


var timer_label: Label


func _ready() -> void:
	# Find the timer UI
	timer_label = get_tree().get_first_node_in_group("timer_label")

	if timer_label:
		timer_label.visible = false
		timer_label.text = ""

	# Give the scene one frame to initialize
	await get_tree().process_frame

	# Start the level
	await start_level()


func start_level() -> void:
	# Wait for the block-building animation if one exists
	var builder = get_tree().get_first_node_in_group("build_controller")

	if builder:
		await builder.build_finished

	# Countdown before gameplay starts
	await countdown_to_start()

	game_started = true

	print("GAME STARTED")


func countdown_to_start() -> void:
	if timer_label:
		timer_label.visible = true

	var count := 0

	while count > 0:
		if timer_label:
			timer_label.text = str(count)

		await get_tree().create_timer(1.0).timeout

		count -= 1

	if timer_label:
		timer_label.text = "shoot boxes"

	await get_tree().create_timer(0.7).timeout

	if timer_label:
		timer_label.visible = false
		timer_label.text = ""


func _process(delta: float) -> void:
	if level_finished:
		return

	if not game_started:
		return

	# Check whether all blocks have landed
	if all_blocks_on_ground():
		start_next_level_countdown()
		return

	# Start the 30-second countdown when ammunition is empty
	if not countdown_active and is_ammo_empty():
		start_restart_countdown()

	# Update active countdown
	if countdown_active:
		remaining_time -= delta

		update_timer_label()

		if remaining_time <= 0.0:
			restart_level()


func start_restart_countdown() -> void:
	countdown_active = true
	remaining_time = restart_countdown

	if timer_label:
		timer_label.visible = true

	print("30 second countdown started")


func start_next_level_countdown() -> void:
	if level_finished:
		return

	level_finished = true

	await countdown_to_next_level()

	load_next_level()


func countdown_to_next_level() -> void:
	if timer_label:
		timer_label.visible = true

	var count := int(next_level_countdown)

	while count > 0:
		if timer_label:
			timer_label.text = str(count)

		await get_tree().create_timer(1.0).timeout

		count -= 1

	if timer_label:
		timer_label.text = "NEXT LEVEL"

	await get_tree().create_timer(0.7).timeout


func update_timer_label() -> void:
	if timer_label:
		timer_label.text = "Time: %.1f" % max(remaining_time, 0.0)


func restart_level() -> void:
	print("Time expired - restarting level")

	get_tree().reload_current_scene()


func load_next_level() -> void:
	print("Loading next level...")

	if timer_label:
		timer_label.visible = false
		timer_label.text = ""

	if next_scene != "":
		get_tree().change_scene_to_file(next_scene)
	else:
		print("ERROR: No next scene assigned!")


func is_ammo_empty() -> bool:
	var cannon = get_tree().get_first_node_in_group("cannon")

	if cannon:
		return cannon.current_ammo <= 0

	return false


func all_blocks_on_ground() -> bool:
	var blocks = get_tree().get_nodes_in_group("level_blocks")

	if blocks.is_empty():
		return false

	for block in blocks:

		if not block.has_method("is_block_on_ground"):
			print(
				"ERROR: ",
				block.name,
				" does not have PhysicalBlock script!"
			)

			return false

		if not block.is_block_on_ground():
			return false

	return true
