extends Node

@export var next_scene: String
@export var restart_time: float = 30.0

var countdown_active := false
var remaining_time := 0.0
var level_finished := false


func _ready():
	var timer_label = get_tree().get_first_node_in_group("timer_label")

	if timer_label:
		timer_label.visible = false
		timer_label.text = ""


func all_blocks_on_ground() -> bool:
	var blocks = get_tree().get_nodes_in_group("level_blocks")
	
	if blocks.is_empty():
		return false

	for block in blocks:
		if not block.is_on_ground:
			return false

	print("geschft")
	return true



func _process(delta):
	if level_finished:
		return

	if all_blocks_on_ground():
		load_next_level()
		return

	if not countdown_active and is_ammo_empty():
		start_countdown()

	if countdown_active:
		remaining_time -= delta
		update_timer_label()

		if remaining_time <= 0:
			restart_level()


func start_countdown():
	countdown_active = true
	remaining_time = restart_time

	var timer_label = get_tree().get_first_node_in_group("timer_label")

	if timer_label:
		timer_label.visible = true
		timer_label.text = "Time: 30"


func update_timer_label():
	var timer_label = get_tree().get_first_node_in_group("timer_label")

	if timer_label:
		timer_label.text = "Time: %.1f" % max(remaining_time, 0.0)


func restart_level():
	get_tree().reload_current_scene()


func load_next_level():
	level_finished = true

	var timer_label = get_tree().get_first_node_in_group("timer_label")

	if timer_label:
		timer_label.visible = false
		timer_label.text = ""

	if next_scene != "":
		get_tree().change_scene_to_file(next_scene)


func is_ammo_empty() -> bool:
	var cannon = get_tree().get_first_node_in_group("cannon")

	if cannon:
		return cannon.current_ammo <= 0

	return false
