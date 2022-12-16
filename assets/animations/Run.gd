extends Node2D

signal completed(action)
signal hit(action, location, direction)

func start(action: Dictionary):
	await get_tree().create_timer(3).timeout
	emit_signal("hit", action, Vector2.ZERO, "lol")
	await get_tree().create_timer(1.5).timeout
	emit_signal("completed", action)
	queue_free()
