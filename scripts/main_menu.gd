extends Node3D

@onready var showCredits = false 

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/mehr_Flip_Test.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_credits_pressed() -> void:
	var animation = "show_credits" if !showCredits else "show_menu"
	$AnimationPlayer.play(animation)


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	showCredits = anim_name == "show_credits"

func _on_deactivate_cam_motion_toggled(toggled_on: bool) -> void:
	Global.deactivate_camera_motion = toggled_on
