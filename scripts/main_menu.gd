extends Node3D


func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/test_level.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_credits_pressed() -> void:
	$AnimationPlayer.play("new_animation")
