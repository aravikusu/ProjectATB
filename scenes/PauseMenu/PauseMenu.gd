extends Control

var flavor = [
	"... is returning shortly!",
	"... is customizing your experience!"
]

func handleInputs():
	if Input.is_action_just_pressed("pause"):
		unpause()

func _process(_delta):
	handleInputs()

@onready var player = $AnimationPlayer
func showPause():
	player.play("fade")
	visible = true

func unpause():
	get_tree().paused = false
	player.play_backwards("fade")
	await player.animation_finished
	queue_free()
