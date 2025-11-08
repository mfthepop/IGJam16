extends Area3D

@onready var UI = get_tree().get_first_node_in_group("UI")

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("PlayerCharacter"):
		if UI:
			UI.cheese_number = UI.cheese_number + 1
			UI.show_cheese()
			self.queue_free()
