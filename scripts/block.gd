extends RigidBody3D

var is_on_ground := false

func _ready():
	add_to_group("level_blocks")
