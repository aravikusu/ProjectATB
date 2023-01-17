extends Node3D

signal targetingComplete(targets)

var currentTargetingMode = Enums.TARGET_TYPE.NONE
var users = []
var hoveringOver = null
var targetDetails = []
var areas = []
var drawnMeshes = []

var targetIdx = 0
var targetSwitch = true
var goodGuys = []
var badGuys = []

var justEntered = true

func handleInputs():
	if Input.is_action_just_pressed("ui_left") \
	or Input.is_action_just_pressed("ui_right"):
		noLongerConsideredTarget()
		targetIdx = 0
		targetSwitch = !targetSwitch
	
	var currentActorArray = []
	if targetSwitch:
		currentActorArray = badGuys
	else:
		currentActorArray = goodGuys
	
	if Input.is_action_just_pressed("ui_down"):
		noLongerConsideredTarget()
		if targetIdx +1 >= currentActorArray.size():
			targetIdx = 0
		else:
			targetIdx += 1
	
	if Input.is_action_just_pressed("ui_up"):
		noLongerConsideredTarget()
		if targetIdx -1 < 0:
			targetIdx = currentActorArray.size() - 1
		else:
			targetIdx -= 1
	
	consideredTarget(currentActorArray[targetIdx])
	
	if Input.is_action_just_pressed("ui_select"):
		addTarget(hoveringOver)

# Called every frame. 'delta' is the elapsed time since the previous frame.
@onready var canvas = $CanvasLayer
@onready var selector = $ActorSelector
@onready var highlight = $ActorHighlight
func _process(_delta):
	if Global.BATTLE_TARGETING_MODE:
		canvas.visible = true
		handleInputs()
	else:
		canvas.visible = false

func draw():
	match currentTargetingMode:
		Enums.TARGET_TYPE.LINE:
			# Draw a line from the users to the target.
			# Any overlapping enemies should also be hit...
			if hoveringOver != null:
				for user in users:
					var start = user.global_position
					var endPos = hoveringOver.global_position
					drawLine(start, endPos, Color("#fc030364"))
		Enums.TARGET_TYPE.SHAPE:
			# There can be multiple shapes... for now there is only Circle, though.
			match targetDetails[0]:
				Enums.TARGET_SHAPE.CIRCLE:
					if hoveringOver != null:
						drawCircle(hoveringOver.global_position, targetDetails[1], Color("#fc030364"))

func drawLine(startPos: Vector3, endPos: Vector3, color: Color) -> void:
	if startPos != endPos:
		var meshInstance = MeshInstance3D.new()
		var cylinderMesh = CylinderMesh.new()
		meshInstance.mesh = cylinderMesh
		meshInstance.cast_shadow = false
		
		meshInstance.position = (startPos + endPos) / 2
		
		meshInstance.look_at_from_position(meshInstance.position, endPos)
		meshInstance.rotate_object_local(Vector3(1, 0, 0), -PI/2)
		
		cylinderMesh.height = startPos.distance_to(endPos)
		cylinderMesh.top_radius = 0.05
		cylinderMesh.bottom_radius = 0.05
		cylinderMesh.material = createMeshMaterial(color)
		
		drawnMeshes.append(meshInstance)
		add_child(meshInstance)
		createArea("line", {
			"mesh": meshInstance
		})

func drawCircle(pos: Vector3, radius: float, color: Color) -> void:
	var meshInstance = MeshInstance3D.new()
	var sphereMesh = SphereMesh.new()
	
	meshInstance.mesh = sphereMesh
	meshInstance.cast_shadow = false
	meshInstance.position = pos
	
	sphereMesh.radius = radius
	sphereMesh.height = radius * 2
	sphereMesh.material = createMeshMaterial(color)
	drawnMeshes.append(meshInstance)
	add_child(meshInstance)
	createArea("circle", {
		"position": pos,
		"radius": radius
	})

func createMeshMaterial(color: Color) -> ORMMaterial3D:
	var meshMaterial = ORMMaterial3D.new()
	
	meshMaterial.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	meshMaterial.albedo_color = color
	meshMaterial.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	
	return meshMaterial

func createArea(shape: String, deets: Dictionary):
	var area = Area3D.new()
	var collision = CollisionShape3D.new()
	var collisionShape
	
	# Setting collision by code is LAME
	# pls
	area.set_collision_layer_value(1, false)
	area.set_collision_layer_value(4, true)
	
	area.set_collision_mask_value(1, false)
	area.set_collision_mask_value(3, true)
	area.set_collision_mask_value(2, true)
	
	add_child(area)
	match shape:
		"line":
			collisionShape = CylinderShape3D.new()
			collisionShape.radius = 0.05
			collisionShape.height = deets.mesh.mesh.height
			area.global_transform = deets.mesh.global_transform
		"circle":
			collisionShape = SphereShape3D.new()
			collisionShape.radius = deets.radius
			area.global_position = deets.position
	
	collision.shape = collisionShape
	area.add_child(collision)
	areas.append(area)

func checkOverlappingAreas():
	var overlappingEnemies = []
	var mainActors = users
	mainActors.append(hoveringOver)
	for area in areas:
		var overlap = area.get_overlapping_areas()
		for actor in overlap:
			if actor not in mainActors:
				overlappingEnemies.append(actor)
	return overlappingEnemies

func setTargetMode(type: Enums.TARGET_TYPE, actorPositions: Array, additionalTargetDetails: Array):
	currentTargetingMode = type
	users = actorPositions
	if additionalTargetDetails.size() > 0: targetDetails = additionalTargetDetails
	selector.show()
	highlight.show()

func sendActors(actors: Array):
	for actor in actors:
		if actor.playerControlled:
			goodGuys.append(actor)
		else:
			badGuys.append(actor)

func addTarget(_actor):
	var allTargets = [hoveringOver]
	allTargets.append_array(checkOverlappingAreas())
	
	var s = emit_signal("targetingComplete", allTargets)
	
	if s != OK:
		Global.printSignalError("TargetUI", "addTarget", "targetingComplete")

func consideredTarget(actor):
	if hoveringOver != actor:
		hoveringOver = actor
		draw()
		highlightTarget()

func noLongerConsideredTarget():
	hoveringOver = null
	clear()
	draw()

func highlightTarget():
	var height = hoveringOver.getHeight()
	var pos = hoveringOver.global_position
	if justEntered:
		print(height)
		selector.global_position = Vector3(pos.x, (pos.y + height / 2.3), pos.z)
		highlight.global_position = Vector3(pos.x, (pos.y - height / 5), pos.z)
		highlight.setRadius(hoveringOver.hitboxRadius)
		justEntered = false

func end():
	currentTargetingMode = Enums.TARGET_TYPE.NONE
	users = []
	noLongerConsideredTarget()
	targetDetails = []
	targetIdx = 0
	targetSwitch = true
	Global.set_player_targeting(false)

func clear():
	for mesh in drawnMeshes:
		mesh.queue_free()
	drawnMeshes = []
	
	for area in areas:
		area.queue_free()
	areas = []
