extends MeshInstance3D

@export var color: Color

var shader : Shader = preload("res://ui/ActorHighlight/ActorHighlight.gdshader")

func _process(_delta):
	material_override.set_shader_parameter("emission_color", color)

func setColor():
	var material = ShaderMaterial.new()
	
