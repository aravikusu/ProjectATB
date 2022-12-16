extends Node2D

signal completed(action)
signal hit(action, location, direction)

var savedAction

@onready var player = $AnimationPlayer
func start(action: Dictionary):
	savedAction = action
	global_position = action.target[0].global_position
	player.play("idle")
	
	await player.animation_finished
	emit_signal("completed", action)
	queue_free()

func boom():
	emit_signal("hit", savedAction, savedAction.target[0].global_position, "right")
