extends RigidBody3D

var is_on_ground := false
@onready var mesh: MeshInstance3D = $MeshInstance3D


func _ready() -> void:
	add_to_group("level_blocks")
	contact_monitor = true
	max_contacts_reported = 4
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node) -> void:
	if body.is_in_group("ground"):
		is_on_ground = true
		set_block_color(Color.GREEN)

func set_block_color(color: Color) -> void:
	var material := mesh.get_active_material(0)

	if material:
		# Make a unique copy so changing one block
		# doesn't change every other block.
		material = material.duplicate()
		mesh.set_surface_override_material(0, material)

		material.albedo_color = color
		
func is_block_on_ground() -> bool:
	return is_on_ground		
		
		
