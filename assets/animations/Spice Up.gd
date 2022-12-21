extends Node3D

signal completed(action)
signal hit(action, location, direction)

@onready var spice = $SpiceParticles

func start(action: Dictionary):
	spice.global_position = action.actor.global_position
	spice.emitting = true
	await get_tree().create_timer(4).timeout
	emit_signal("completed", action)
	queue_free()
