extends Node2D

@onready var cheese_number = 0
func _process(delta: float) -> void:
	if (cheese_number == 1 ) :
		get_node("CheeseUI1").modulate = Color (1,1,1,1) 
	elif (cheese_number == 2 ) :  
		get_node("CheeseUI2").modulate = Color (1,1,1,1) 
	elif (cheese_number == 3 )  : 
		get_node("CheeseUI3").modulate = Color (1,1,1,1) 		
