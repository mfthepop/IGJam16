extends Marker3D

@export_category("Linking Variables")
@export var linked_teleporter : Marker3D

@export_category("Visibility Variables")
@export var show_debug_shape : bool = false
@export var shape_color : Color = Color(Color.DARK_MAGENTA.r, Color.DARK_MAGENTA.g, Color.DARK_MAGENTA.b, 0.4)

@onready var entered_from_teleport = false

signal teleported_from(where)


func _ready() -> void:
	$Debug.get_active_material(0)
	$Debug.visible = show_debug_shape
	
	var mesh = $Debug.mesh.duplicate()
	var mat = mesh.material.duplicate()
	mat.albedo_color = shape_color
	mesh.material = mat
	$Debug.mesh = mesh

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("PlayerCharacter") && !entered_from_teleport :
		if linked_teleporter:
			teleported_from.emit(self)
			linked_teleporter.entered_from_teleport = true
			body.global_position = linked_teleporter.global_position

func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("PlayerCharacter"):
		entered_from_teleport = false
