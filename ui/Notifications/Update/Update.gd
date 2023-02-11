extends Control


@onready var textLabel = $"%Text"
@onready var bg = $"%BG"
@onready var player = $AnimationPlayer
func prepare(text: String):
	textLabel.text = text
	bg.modulate = Color("#13659896")
	player.play("show")
