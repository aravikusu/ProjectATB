extends Node3D

@onready var player = $AnimationPlayer
@onready var label = $Label
func prepare(location, value, mode):
	label.text = str(value)
	position = Vector3(location.x, location.y + 0.5, location.z)
	player.play("hp")

func _on_animation_player_animation_finished(_anim_name):
	print("bruh")
	queue_free()
