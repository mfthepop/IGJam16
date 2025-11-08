extends Marker3D

@export_category("Linking Variables")
@export var linked_teleporter : Marker3D

@onready var entered_from_teleport = false

signal teleported_from(where)

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("PlayerCharacter") && !entered_from_teleport :
		if linked_teleporter:
			linked_teleporter.entered_from_teleport = true
			body.global_position = linked_teleporter.global_position
			teleported_from.emit(self)

func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("PlayerCharacter"):
		entered_from_teleport = false
