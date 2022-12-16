extends Control

# Shows messages such as "DEAD!" or other statuses.

@onready var player = $AnimationPlayer
@onready var label = $"%Label"
func showDead(location):
	position = Vector2(location.x, location.y - 25)
	label.text = "DEAD"
	label.label_settings.font_color = Color("#c50d00")
	player.play("dead")


func _on_animation_player_animation_finished(_anim_name):
	queue_free()
