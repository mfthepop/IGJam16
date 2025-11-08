extends Area3D

@onready var UI = get_parent().get_node("UI")


func _on_body_entered(body: Node3D) -> void:
	print(body.name)
	if body.is_in_group("PlayerCharacter"):
		UI.cheese_number = UI.cheese_number + 1
		if (UI.cheese_number == 3 ) : 
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			get_tree().paused = false
			get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
		print(UI.cheese_number)
		self.queue_free()
