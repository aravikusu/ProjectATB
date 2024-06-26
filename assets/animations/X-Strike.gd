extends Node3D

signal completed(action)
signal hit(action, location, direction)

func start(action: Dictionary):
	var startPos = action.actor.global_position
	var partnerStart = action.partner.global_position
	var targetPos = action.target[0].global_position
	action.actor.forceMove(targetPos, 6)
	action.partner.forceMove(targetPos, 6)
	await get_tree().create_timer(1).timeout
	emit_signal("hit", action, action.target[0].global_position, "right")
	emit_signal("hit", action, action.target[0].global_position, "left")
	action.actor.forceMove(startPos)
	action.partner.forceMove(partnerStart)
	await get_tree().create_timer(0.1).timeout
	emit_signal("completed", action)
	await get_tree().create_timer(1).timeout
	queue_free()

func calcExtraMovement(direction: Vector3, isPartner: bool):
	var extraMovement = Vector3.ZERO
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
			extraMovement.x += 75
	
	return extraMovement
