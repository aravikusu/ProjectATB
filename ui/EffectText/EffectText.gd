extends Node3D

# Shows messages such as "DEAD!" or other statuses.

@onready var player = $AnimationPlayer
@onready var label = $Label
func showDead(location):
	position = Vector3(location.x, location.y + 0.5, location.z)
	label.text = "DEAD"
	player.play("dead")


func _on_animation_player_animation_finished(_anim_name):
	queue_free()
