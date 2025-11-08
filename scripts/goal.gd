extends Area3D

func _on_body_entered(body: Node3D) -> void:
	print(body.name)
	if body.is_in_group("PlayerCharacter"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		get_tree().paused = false
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
