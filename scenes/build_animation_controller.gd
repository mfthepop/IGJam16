extends Node3D

signal build_finished

@export_category("Build Animation")
@export var ground_block_center_y: float = 0.5
@export_range(0.0, 1.0) var compression: float = 0.05
@export var animation_duration: float = 2.0

var blocks: Array[Node] = []
var build_completed: bool = false


func _ready() -> void:
	add_to_group("build_controller")

	# Wait until all blocks have been created and added to the scene.
	await get_tree().process_frame

	blocks = get_tree().get_nodes_in_group("level_blocks")

	await play_build_animation()

	build_completed = true
	build_finished.emit()


func play_build_animation() -> void:
	if blocks.is_empty():
		print("No level blocks found.")
		return

	var block_data: Array = []
	var lowest_y: float = INF

	# --------------------------------------------------
	# 1. Save the final positions
	# --------------------------------------------------

	for block in blocks:
		if block is RigidBody3D:
			block.freeze = true
			block.sleeping = true

			var final_position: Vector3 = block.global_position
			var final_rotation: Vector3 = block.global_rotation

			lowest_y = min(lowest_y, final_position.y)

			block_data.append({
				"block": block,
				"final_position": final_position,
				"final_rotation": final_rotation
			})

	# --------------------------------------------------
	# 2. Compress the tower down to the ground
	# --------------------------------------------------

	for data in block_data:
		var block: RigidBody3D = data["block"]
		var final_position: Vector3 = data["final_position"]

		var height_from_bottom: float = final_position.y - lowest_y

		var start_y: float = ground_block_center_y \
			+ height_from_bottom * compression

		block.global_position = Vector3(
			final_position.x,
			start_y,
			final_position.z
		)

		block.global_rotation = data["final_rotation"]

	# --------------------------------------------------
	# 3. Make the entire tower rise
	# --------------------------------------------------

	var tween := create_tween()

	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)

	for data in block_data:
		var block: RigidBody3D = data["block"]
		var final_position: Vector3 = data["final_position"]

		tween.tween_property(
			block,
			"global_position",
			final_position,
			animation_duration
		)

	await tween.finished

	# --------------------------------------------------
	# 4. Restore exact final positions
	# --------------------------------------------------

	for data in block_data:
		var block: RigidBody3D = data["block"]

		block.global_position = data["final_position"]
		block.global_rotation = data["final_rotation"]

		block.freeze = false
		block.sleeping = false

	print("Tower build animation finished!")
