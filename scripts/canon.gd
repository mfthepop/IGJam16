extends Node3D

@export_category("Projectile")
@export var projectile_scene: PackedScene
@export var launch_force: float = 30.0
@export var max_distance: float = 1000.0

@export_category("Weapon")
@export var fire_cooldown: float = 0.5

@export_category("Ammo")
@export var max_ammo: int = 10

@onready var camera: Camera3D = get_viewport().get_camera_3d()
@onready var muzzle: Marker3D = $Muzzle
@onready var audio: AudioStreamPlayer3D = $AudioStreamPlayer3D

var ammo_label: Label
var current_ammo: int
var can_fire: bool = true


func _ready() -> void:
	ammo_label = get_tree().get_first_node_in_group("ammo_label")

	current_ammo = max_ammo
	update_ammo_ui()


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("fire") and can_fire:
		fire()


func update_ammo_ui() -> void:
	if ammo_label:
		ammo_label.text = str(current_ammo)
	else:
		print("Ammo Label is not assigned!")


func fire() -> void:
	if not can_fire:
		return

	if current_ammo <= 0:
		print("Out of ammo!")
		return

	if projectile_scene == null:
		print("ERROR: Projectile Scene is not assigned!")
		return

	can_fire = false

	# Optional muzzle flash / weapon animation
	if has_node("MuzzlePoint"):
		$MuzzlePoint.fire()

	current_ammo -= 1
	update_ammo_ui()

	# Find the exact point the crosshair is looking at
	var target_position: Vector3 = get_aim_target()

	# Fire the block from the cannon toward that point
	shoot_block(target_position)

	if audio:
		audio.play()

	await get_tree().create_timer(fire_cooldown).timeout

	can_fire = true


func get_aim_target() -> Vector3:
	# Make sure we have the correct camera
	if camera == null:
		camera = get_viewport().get_camera_3d()

	if camera == null:
		print("ERROR: No Camera3D found!")
		return muzzle.global_position - muzzle.global_transform.basis.z * max_distance

	# --------------------------------------------------
	# CROSSHAIR = CENTER OF SCREEN
	# --------------------------------------------------

	var viewport_size := get_viewport().get_visible_rect().size
	var screen_center := viewport_size * 0.5

	# Ray starts from the camera and goes exactly
	# through the center of the screen / crosshair.
	var ray_origin := camera.project_ray_origin(screen_center)
	var ray_direction := camera.project_ray_normal(screen_center)

	var ray_end := ray_origin + ray_direction * max_distance

	# --------------------------------------------------
	# RAYCAST
	# --------------------------------------------------

	var query := PhysicsRayQueryParameters3D.create(
		ray_origin,
		ray_end
	)

	# Don't let the aiming ray hit the player/cannon.
	query.exclude = [
		get_parent(),
		get_parent().get_parent(),
		self
	]

	query.collide_with_bodies = true
	query.collide_with_areas = true

	var space_state := get_world_3d().direct_space_state
	var result := space_state.intersect_ray(query)

	if result:
		return result.position

	# Nothing hit: aim at a point far away
	return ray_end


func shoot_block(target_position: Vector3) -> void:
	var block := projectile_scene.instantiate()

	get_tree().current_scene.add_child(block)

	# --------------------------------------------------
	# SPAWN AT CANNON MUZZLE
	# --------------------------------------------------

	block.global_position = muzzle.global_position

	# --------------------------------------------------
	# AIM FROM MUZZLE TO CROSSHAIR TARGET
	# --------------------------------------------------

	var direction := (
		target_position - muzzle.global_position
	).normalized()

	# --------------------------------------------------
	# SHOOT
	# --------------------------------------------------

	if block is RigidBody3D:
		block.apply_central_impulse(direction * launch_force)
	else:
		print("ERROR: Projectile must be a RigidBody3D!")
