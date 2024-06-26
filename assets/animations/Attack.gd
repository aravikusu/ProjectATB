extends Node3D

signal completed(action)
signal hit(action, location, direction)

func start(action: Dictionary):
	var startPos = action.actor.global_position
	action.actor.forceMove(action.target[0].global_position)
	await get_tree().create_timer(1).timeout
	emit_signal("hit", action, action.target[0].global_position, "right")
	action.actor.forceMove(startPos)
	await get_tree().create_timer(0.1).timeout
	emit_signal("completed", action)
	await get_tree().create_timer(1).timeout
	queue_free()
