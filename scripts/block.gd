extends RigidBody3D

var is_on_ground := false


func _ready() -> void:
	add_to_group("level_blocks")


func _on_body_entered(body: Node) -> void:
	print("================================")
	print("BODY ENTERED!")
	print("My block: ", name)
	print("Other body: ", body.name)
	print("Other type: ", body.get_class())
	print("================================")
