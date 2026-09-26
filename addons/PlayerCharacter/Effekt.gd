extends Node3D

@export var flash_duration: float = 0.08
@export var light_energy_max: float = 12.0
@export var light_falloff_time: float = 0.1
@export var flash_color: Color = Color(1.0, 0.7, 0.2)
@export var smoke_color: Color = Color(0.35, 0.35, 0.35)
@export var muzzle_direction: Vector3 = Vector3(0, 0, -1)  # Rohrachse anpassen

var flash_mesh: MeshInstance3D
var flash_particles: GPUParticles3D
var smoke_particles: GPUParticles3D
var flash_light: OmniLight3D


func _ready() -> void:
	_setup_flash_mesh()
	_setup_flash_particles()
	_setup_smoke_particles()
	_setup_light()


func _setup_flash_mesh() -> void:
	flash_mesh = MeshInstance3D.new()
	var quad := QuadMesh.new()
	quad.size = Vector2(0.6, 0.6)
	flash_mesh.mesh = quad

	var mat := StandardMaterial3D.new()
	mat.shading_mode = StandardMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = flash_color
	mat.emission_enabled = true
	mat.emission = flash_color
	mat.emission_energy_multiplier = 4.0
	mat.transparency = StandardMaterial3D.TRANSPARENCY_ALPHA
	mat.billboard_mode = StandardMaterial3D.BILLBOARD_ENABLED
	flash_mesh.material_override = mat
	flash_mesh.visible = false

	add_child(flash_mesh)


func _setup_flash_particles() -> void:
	flash_particles = GPUParticles3D.new()
	flash_particles.emitting = false
	flash_particles.one_shot = true
	flash_particles.explosiveness = 1.0
	flash_particles.amount = 24
	flash_particles.lifetime = 0.3

	var pm := ParticleProcessMaterial.new()
	pm.direction = muzzle_direction
	pm.spread = 15.0
	pm.initial_velocity_min = 3.0
	pm.initial_velocity_max = 6.0
	pm.gravity = Vector3(0, -2.0, 0)
	pm.scale_min = 0.05
	pm.scale_max = 0.15

	var ramp := Gradient.new()
	ramp.set_color(0, Color(1.0, 0.9, 0.5, 1.0))
	ramp.set_color(1, Color(0.2, 0.2, 0.2, 0.0))
	var ramp_tex := GradientTexture1D.new()
	ramp_tex.gradient = ramp
	pm.color_ramp = ramp_tex

	flash_particles.process_material = pm

	var draw_mesh := SphereMesh.new()
	draw_mesh.radius = 0.05
	draw_mesh.height = 0.1
	flash_particles.draw_pass_1 = draw_mesh

	add_child(flash_particles)


func _setup_smoke_particles() -> void:
	smoke_particles = GPUParticles3D.new()
	smoke_particles.emitting = false
	smoke_particles.one_shot = true
	smoke_particles.explosiveness = 0.8
	smoke_particles.amount = 16
	smoke_particles.lifetime = 1.5

	var pm := ParticleProcessMaterial.new()
	pm.direction = muzzle_direction + Vector3(0, 1, 0)
	pm.spread = 30.0
	pm.initial_velocity_min = 0.5
	pm.initial_velocity_max = 1.5
	pm.gravity = Vector3(0, 0.3, 0)
	pm.scale_min = 0.3
	pm.scale_max = 0.8

	var ramp := Gradient.new()
	ramp.set_color(0, Color(smoke_color.r, smoke_color.g, smoke_color.b, 0.5))
	ramp.set_color(1, Color(smoke_color.r, smoke_color.g, smoke_color.b, 0.0))
	var ramp_tex := GradientTexture1D.new()
	ramp_tex.gradient = ramp
	pm.color_ramp = ramp_tex

	smoke_particles.process_material = pm

	var draw_mesh := SphereMesh.new()
	draw_mesh.radius = 0.2
	draw_mesh.height = 0.4
	smoke_particles.draw_pass_1 = draw_mesh

	add_child(smoke_particles)


func _setup_light() -> void:
	flash_light = OmniLight3D.new()
	flash_light.light_color = flash_color
	flash_light.light_energy = 0.0
	flash_light.omni_range = 4.0

	add_child(flash_light)


func fire() -> void:
	flash_mesh.visible = true

	flash_particles.restart()
	flash_particles.emitting = true

	smoke_particles.restart()
	smoke_particles.emitting = true

	flash_light.light_energy = light_energy_max
	var tween := create_tween()
	tween.tween_property(flash_light, "light_energy", 0.0, light_falloff_time)

	await get_tree().create_timer(flash_duration).timeout
	flash_mesh.visible = false
