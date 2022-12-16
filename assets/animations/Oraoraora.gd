extends Node2D

signal completed(action)
signal hit(action, location, direction)

var hitSpeed = 0.08

func start(action: Dictionary):
	var startPos = action.actor.global_position
	action.actor.moveToLocation(action.target[0].global_position)
	
	var direction = "right"
	for hit in 100:
		await get_tree().create_timer(hitSpeed).timeout
		emit_signal("hit", action, action.target[0].global_position, direction)
		
		if direction == "right":
			direction = "left"
		else:
			direction = "right"
		if hit % 25 == 0:
			hitSpeed -= 0.02
	action.actor.moveToLocation(startPos)
	await get_tree().create_timer(0.1).timeout
	emit_signal("completed", action)
	await get_tree().create_timer(1).timeout
	queue_free()
