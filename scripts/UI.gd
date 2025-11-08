extends Control

@onready var cheese_number = 0

const max_cheese = 3

func show_cheese():
	var name = "CheeseUI" + str(cheese_number)
	var cheese = get_node("Icons").get_node(name)
	if cheese:
		cheese.modulate = Color (1,1,1,1) 
		
	$AudioStreamPlayer.play()
		
	if (cheese_number == max_cheese ) : 
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		get_tree().paused = false
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
