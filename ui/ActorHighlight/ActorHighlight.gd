extends MeshInstance3D

@export var color: Color:
	set(newColor):
		color = newColor
		setColor()

var scanShader : Shader = preload("res://assets/shaders/scan.gdshader")

func setColor():
	var scanMaterial = ShaderMaterial.new()
	scanMaterial.shader = scanShader
	scanMaterial.set_shader_parameter("scan_color", color)
	scanMaterial.set_shader_parameter("time_shift_scale", Vector3(0.5, 0, 0))
	scanMaterial.set_shader_parameter("scan_power", Vector3(0.5, 0, 0))
	scanMaterial.set_shader_parameter("scan_line_size", 1.5)
	material_overlay = scanMaterial

func setRadius(radius: float, instant = true):
	if instant:
		mesh.inner_radius = radius
		mesh.outer_radius = radius + 0.057
	else:
		var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
		tween.parallel().tween_property(mesh, "inner_radius", radius, 0.5)
		tween.parallel().tween_property(mesh, "outer_radius", radius + 0.057, 0.5)
