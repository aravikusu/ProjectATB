extends Node3D

signal completed(action)
signal hit(action, location, direction)

func start(action: Dictionary):
	await get_tree().create_timer(1).timeout
	emit_signal("completed", action)
	queue_free()
