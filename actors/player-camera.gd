extends Camera3D

var mouse = Vector2()

var lastHovered = {}

func _input(event):
	if Global.get_game_state() == Enums.GAME_STATE.BATTLE:
		if event is InputEventMouse:
			mouse = event.position
			hover()
	
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			select()

func cast() -> Dictionary:
	var worldspace = get_world_3d().direct_space_state
	var params = PhysicsRayQueryParameters3D.new()
	params.from = project_ray_origin(mouse)
	params.to = project_position(mouse, 1000)
	return worldspace.intersect_ray(params)

func hover() -> void:
	var intersected = cast()
	checkLastHovered(intersected)
	if intersected.has("collider"):
		var collider: Object = intersected.collider
		if collider.has_method("hover"):
			collider.hover()

func select() -> void:
	var intersected = cast()
	if intersected.has("collider"):
		var collider: Object = intersected.collider
		if collider.has_method("click"):
			collider.click()

func checkLastHovered(currentHover: Dictionary) -> void:
	var checkUnhover = false
	if lastHovered.has("collider"):
		if currentHover.has("collider"):
			if lastHovered.collider != currentHover.collider:
				checkUnhover = true
		else:
			checkUnhover = true
	
	if checkUnhover:
		if lastHovered.collider.has_method("unhover"):
			lastHovered.collider.unhover()
	
	lastHovered = currentHover
