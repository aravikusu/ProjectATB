extends Node3D

signal completed(action)
signal hit(action, location, direction)

func start(action: Dictionary):
	global_position = action.target[0].global_position
	$GPUParticles3D.emitting = true
	
	await get_tree().create_timer(2.5).timeout
	emit_signal("hit", action, action.target[0].global_position, "right")
	emit_signal("completed", action)
	await get_tree().create_timer(5).timeout
	queue_free()
