extends Node3D

@export var projectile_scene: PackedScene
@export var launch_force: float = 30.0
@export var max_distance: float = 1000.0
@export var fire_cooldown: float = 0.5

@onready var camera: Camera3D = get_viewport().get_camera_3d()
@onready var muzzle: Marker3D = $Muzzle
@onready var audio: AudioStreamPlayer3D = $AudioStreamPlayer3D

var can_fire := true


func _process(_delta):
	if Input.is_action_just_pressed("fire") and can_fire:
		fire()


func fire():
	if not can_fire:
		return

	can_fire = false

	var target = get_aim_target()

	if target != null:
		shoot_block(target)

	if audio:
		audio.play()

	await get_tree().create_timer(fire_cooldown).timeout
	can_fire = true


func get_aim_target():
	var viewport_size = get_viewport().get_visible_rect().size

	# Center of the screen
	var screen_center = viewport_size / 2.0

	var ray_origin = camera.project_ray_origin(screen_center)
	var ray_direction = camera.project_ray_normal(screen_center)

	var ray_end = ray_origin + ray_direction * max_distance

	var query = PhysicsRayQueryParameters3D.create(
		ray_origin,
		ray_end
	)

	# Don't hit the player
	query.exclude = [get_parent().get_parent()]

	var space_state = get_world_3d().direct_space_state
	var result = space_state.intersect_ray(query)

	if result:
		return result.position

	return ray_end


func shoot_block(target_position: Vector3):
	var block = projectile_scene.instantiate()

	get_tree().current_scene.add_child(block)

	# Start slightly in front of the cannon
	block.global_position = muzzle.global_position

	# Direction from cannon muzzle to where player is aiming
	var direction = (
		target_position - muzzle.global_position
	).normalized()

	block.apply_central_impulse(direction * launch_force)
