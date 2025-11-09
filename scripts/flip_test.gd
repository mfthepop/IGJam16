extends Node3D


func _on_teleport_point_teleported_from(where: Variant) -> void:
	$Level.rotate(Vector3(1, 0 , 0), 3.14159)
