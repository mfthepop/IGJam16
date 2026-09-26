extends Node

@export var next_scene: String
@export var restart_time: float = 30.0

var countdown_active := false
var remaining_time := 0.0
var level_finished := false


func _process(delta):
	if level_finished:
		return

	# Check if all blocks are on the ground
	if all_blocks_on_ground():
		load_next_level()
		return

	# Start countdown when ammo reaches zero
	if not countdown_active and is_ammo_empty():
		start_countdown()

	# Countdown
	if countdown_active:
		remaining_time -= delta

		update_timer_ui()

		if remaining_time <= 0:
			restart_level()


func all_blocks_on_ground() -> bool:
	var blocks = get_tree().get_nodes_in_group("level_blocks")

	if blocks.is_empty():
		return false

	for block in blocks:
		if not block.is_on_ground:
			return false

	return true


func start_countdown():
	countdown_active = true
	remaining_time = restart_time

	print("Ammo empty! You have 30 seconds.")


func restart_level():
	print("Time expired. Restarting level...")

	get_tree().reload_current_scene()


func load_next_level():
	level_finished = true

	print("Level complete!")

	if next_scene != "":
		get_tree().change_scene_to_file(next_scene)


func is_ammo_empty() -> bool:
	var cannon = get_tree().get_first_node_in_group("cannon")

	if cannon:
		return cannon.current_ammo <= 0

	return false


func update_timer_ui():
	var timer_label = get_tree().get_first_node_in_group("timer_label")

	if timer_label:
		timer_label.text = "Time: %.1f" % remaining_time
