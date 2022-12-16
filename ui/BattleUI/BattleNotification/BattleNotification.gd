extends Control


@onready var messageLabel = $MarginContainer/Label
@onready var player = $AnimationPlayer
func showMessage(message, actor):
	var finalText = message.replace("%a", actor)
	messageLabel.text = finalText
	player.play("fade")

func targetMessage(command):
	messageLabel.text = command + "..."
	player.play("stickMessage")

func unstickMessage():
	player.play_backwards("stickMessage")
