extends Control

var flavor = [
	"... is returning shortly!",
	"... is customizing your experience!"
]

@onready var player = $AnimationPlayer
func showPause():
	player.play("fade")
	visible = true

func unpause():
	get_tree().paused = false
	player.play_backwards("fade")
	await player.animation_finished
	queue_free()


func _input(event):
	if event.is_action_pressed("ui_cancel"):
		unpause()
