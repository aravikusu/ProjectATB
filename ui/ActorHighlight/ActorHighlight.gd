extends MeshInstance3D

@export var color: Color:
	set(newColor):
		color = newColor
		setColor()

var highlightShader : Shader = preload("res://assets/shaders/highlight.gdshader")
var scanShader : Shader = preload("res://assets/shaders/scan.gdshader")

func setColor():
	var highlightMaterial = ShaderMaterial.new()
	highlightMaterial.shader = highlightShader
	highlightMaterial.set_shader_parameter("emission_color", color)
	material_override = highlightMaterial
	
	var scanMaterial = ShaderMaterial.new()
	scanMaterial.shader = scanShader
	scanMaterial.set_shader_parameter("scan_color", color)
	scanMaterial.set_shader_parameter("time_shift_scale", Vector3(0.5, 0, 0))
	scanMaterial.set_shader_parameter("scan_power", Vector3(0.5, 0, 0))
	scanMaterial.set_shader_parameter("scan_line_size", 1.5)
	material_overlay = scanMaterial

func setRadius(radius: float):
	mesh.inner_radius = radius
	mesh.outer_radius = radius + 0.057
