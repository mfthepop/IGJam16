extends RigidBody3D

var is_on_ground := false


func _ready() -> void:
	add_to_group("level_blocks")
	contact_monitor = true
	max_contacts_reported = 4
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node) -> void:
	if body.is_in_group("ground"):
		is_on_ground = true
