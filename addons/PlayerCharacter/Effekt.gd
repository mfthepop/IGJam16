extends Node3D

@export var flash_duration: float = 0.08
@export var light_energy_max: float = 12.0
@export var light_falloff_time: float = 0.1
@export var flash_color: Color = Color(1.0, 0.7, 0.2)
@export var smoke_color: Color = Color(0.35, 0.35, 0.35)
@export var muzzle_direction: Vector3 = Vector3(0, 0, -1)  # Rohrachse anpassen

var flash_mesh: MeshInstance3D
var flash_particles: GPUParticles3D
var flash_light: OmniLight3D


func _ready() -> void:
	_setup_flash_mesh()
	_setup_flash_particles()
	_setup_light()


func _setup_flash_mesh() -> void:
	flash_mesh = MeshInstance3D.new()
	flash_mesh.mesh = _create_star_mesh(5, 0.35, 0.14)

	var mat := StandardMaterial3D.new()
	mat.shading_mode = StandardMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = flash_color
	mat.emission_enabled = true
	mat.emission = flash_color
	mat.emission_energy_multiplier = 4.0
	mat.transparency = StandardMaterial3D.TRANSPARENCY_ALPHA
	mat.billboard_mode = StandardMaterial3D.BILLBOARD_ENABLED
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	flash_mesh.material_override = mat
	flash_mesh.visible = false

	add_child(flash_mesh)


func _create_star_mesh(num_points: int, outer_radius: float, inner_radius: float) -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)

	var total_points := num_points * 2
	var verts: Array[Vector3] = []
	for i in total_points:
		var angle := i * PI / num_points
		var radius := outer_radius if i % 2 == 0 else inner_radius
		verts.append(Vector3(cos(angle) * radius, sin(angle) * radius, 0.0))

	var center := Vector3.ZERO
	for i in total_points:
		var next_i := (i + 1) % total_points
		st.add_vertex(center)
		st.add_vertex(verts[i])
		st.add_vertex(verts[next_i])

	st.generate_normals()
	return st.commit()


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

	var flash_particle_mat := StandardMaterial3D.new()
	flash_particle_mat.shading_mode = StandardMaterial3D.SHADING_MODE_UNSHADED
	flash_particle_mat.vertex_color_use_as_albedo = true
	flash_particle_mat.transparency = StandardMaterial3D.TRANSPARENCY_ALPHA
	draw_mesh.material = flash_particle_mat

	flash_particles.draw_pass_1 = draw_mesh

	add_child(flash_particles)


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

	_spawn_smoke_burst(32, 1.5, 0.8)
	_spawn_lingering_smoke()

	flash_light.light_energy = light_energy_max
	var tween := create_tween()
	tween.tween_property(flash_light, "light_energy", 0.0, light_falloff_time)

	await get_tree().create_timer(flash_duration).timeout
	if flash_mesh:
		flash_mesh.visible = false


func _spawn_smoke_burst(amount: int, lifetime: float, explosiveness: float) -> void:
	var smoke := GPUParticles3D.new()
	smoke.emitting = false
	smoke.one_shot = true
	smoke.explosiveness = explosiveness
	smoke.amount = amount
	smoke.lifetime = lifetime

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

	smoke.process_material = pm

	var draw_mesh := SphereMesh.new()
	draw_mesh.radius = 0.2
	draw_mesh.height = 0.4

	var smoke_mat := StandardMaterial3D.new()
	smoke_mat.shading_mode = StandardMaterial3D.SHADING_MODE_UNSHADED
	smoke_mat.vertex_color_use_as_albedo = true
	smoke_mat.transparency = StandardMaterial3D.TRANSPARENCY_ALPHA
	draw_mesh.material = smoke_mat

	smoke.draw_pass_1 = draw_mesh

	get_tree().current_scene.add_child(smoke)
	smoke.global_transform = global_transform
	smoke.emitting = true

	await get_tree().create_timer(smoke.lifetime + 0.5).timeout
	if is_instance_valid(smoke):
		smoke.queue_free()


func _spawn_lingering_smoke() -> void:
	var elapsed := 0.0
	var interval := 0.35
	while elapsed < 2.0:
		await get_tree().create_timer(interval).timeout
		if not is_inside_tree():
			return
		_spawn_smoke_burst(6, 1.0, 0.6)
		elapsed += interval
