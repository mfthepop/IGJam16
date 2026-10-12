extends CanvasLayer


func _on_quit_pressed() -> void:
	get_tree().quit()



func _on_continue_pressed() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	get_tree().paused = false
	self.visible = false
