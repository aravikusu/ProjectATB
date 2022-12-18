extends Node2D

signal completed(action)
signal hit(action, location, direction)

func start(action: Dictionary):
	var startPos = action.actor.global_position
	var partnerStart = action.partner.global_position
	var targetPos = action.target[0].global_position
	action.actor.moveToLocation(targetPos + calcExtraMovement(targetPos - startPos, false))
	action.partner.moveToLocation(targetPos + calcExtraMovement(targetPos - partnerStart, true))
	await get_tree().create_timer(1).timeout
	emit_signal("hit", action, action.target[0].global_position, "right")
	emit_signal("hit", action, action.target[0].global_position, "left")
	action.actor.moveToLocation(startPos)
	action.partner.moveToLocation(partnerStart)
	await get_tree().create_timer(0.1).timeout
	emit_signal("completed", action)
	await get_tree().create_timer(1).timeout
	queue_free()

func calcExtraMovement(direction: Vector2, isPartner: bool):
	var extraMovement = Vector2.ZERO
	var wentSideways = false
	if direction.x < 0:
		wentSideways = true
		extraMovement.x -= 75
	
	if direction.x > 0:
		wentSideways = true
		extraMovement.x += 75
	
	if direction.y < 0:
		extraMovement.y -= 75
	
	if direction.y > 0:
		extraMovement.y += 75
	
	if wentSideways:
		if isPartner:
			extraMovement.y -= 75
		else:
			extraMovement.y += 75
	else:
		if isPartner:
			extraMovement.x -= 75
		else:
			extraMovement.y += 75
	
	return extraMovement
