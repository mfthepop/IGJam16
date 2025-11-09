@tool
extends Marker3D

@export_category("Linking Variables")
@export var linked_teleporter : Marker3D

@export_category("Visibility Variables")
@export var show_debug_shape : bool = false
@export var show_link_line : bool = true
@export var shape_color : Color = Color(1.0, 0.0, 1.0, 0.6)

@onready var entered_from_teleport := false
var _last_link_line_state: bool = true
var _syncing := false

signal teleported_from(where)


func _ready() -> void:
	if is_instance_valid($Debug) and $Debug.mesh != null:
		var mesh = $Debug.mesh.duplicate()
		if mesh and mesh.material:
			var mat = mesh.material.duplicate()
			mat.set_shader_parameter("tint_color", shape_color)
			mesh.material = mat
			$Debug.mesh = mesh
		$Debug.visible = show_debug_shape

	if not is_instance_valid($LinkLine):
		push_warning("Erwarte einen MeshInstance3D-Knoten namens 'LinkLine' als Kind.")
		return

	_draw_teleport_link()


func _process(_delta: float) -> void:
	#Engine
	if Engine.is_editor_hint():
		render_lines()
	#Ingame
	else:
		render_lines()


func render_lines():
	_update_link_visibility()
	if show_link_line:
		_draw_teleport_link()
	else:
		_clear_linkline_mesh()


func _update_link_visibility() -> void:
	if _syncing:
		return
	if not is_instance_valid(linked_teleporter):
		return
	if show_link_line == _last_link_line_state:
		return

	# Status hat sich geändert → auf Partner anwenden
	_syncing = true
	linked_teleporter.show_link_line = show_link_line
	linked_teleporter._last_link_line_state = show_link_line
	_syncing = false

	_last_link_line_state = show_link_line


func _draw_teleport_link() -> void:
	if not is_instance_valid($LinkLine):
		return
	if not show_link_line or not is_instance_valid(linked_teleporter):
		_clear_linkline_mesh()
		return

	var link_node: MeshInstance3D = $LinkLine
	link_node.visible = true

	var imesh := ImmediateMesh.new()
	imesh.clear_surfaces()
	imesh.surface_begin(Mesh.PRIMITIVE_LINES)
	imesh.surface_set_color(shape_color)

	var a_local = link_node.to_local(global_transform.origin)
	var b_local = link_node.to_local(linked_teleporter.global_transform.origin)
	imesh.surface_add_vertex(a_local)
	imesh.surface_add_vertex(b_local)

	imesh.surface_end()
	link_node.mesh = imesh

	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(shape_color.r, shape_color.g, shape_color.b, 1.0)
	mat.flags_unshaded = true
	mat.flags_transparent = true
	link_node.set_surface_override_material(0, mat)


func _clear_linkline_mesh() -> void:
	if not is_instance_valid($LinkLine):
		return
	var link_node: MeshInstance3D = $LinkLine
	link_node.visible = false
	link_node.mesh = null


# --- Teleport-Logik ---
func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("PlayerCharacter") and not entered_from_teleport:
		if linked_teleporter:
			teleported_from.emit(self)
			linked_teleporter.entered_from_teleport = true
			body.global_position = linked_teleporter.global_position


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("PlayerCharacter"):
		entered_from_teleport = false


func _on_area_3d_area_entered(area: Area3D) -> void:
	print(area.name)
	if area.name == "NearDetection":
		show_link_line = true 


func _on_area_3d_area_exited(area: Area3D) -> void:
	if area.name == "NearDetection":
		show_link_line = false 
