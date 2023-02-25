extends Label3D

@onready var player = $AnimationPlayer
func prepare(location, value, mode):
	text = str(value)
	position = Vector3(location.x, location.y + 0.5, location.z)
	player.play(mode)

func _on_animation_player_animation_finished(_anim_name):
	queue_free()
