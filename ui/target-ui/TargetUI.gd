extends Node3D

signal targetingComplete(targets)

var currentTargetingMode = Enums.TARGET_TYPE.NONE
var actors = []
var hoveringOver = null
var targetDetails = []
var areas = []
var drawnMeshes = []

# Called every frame. 'delta' is the elapsed time since the previous frame.
@onready var canvas = $CanvasLayer
func _process(_delta):
	if Global.BATTLE_TARGETING_MODE:
		canvas.visible = true
	else:
		canvas.visible = false

func draw():
	match currentTargetingMode:
		Enums.TARGET_TYPE.LINE:
			# Draw a line from the actors to the target.
			# Any overlapping enemies should also be hit...
			if hoveringOver != null:
				for actor in actors:
					var start = actor.global_position
					var endPos = hoveringOver.global_position
					drawLine2(start, endPos, Color("#fc030364"))
		Enums.TARGET_TYPE.SHAPE:
			# There can be multiple shapes... for now there is only Circle, though.
			match targetDetails[0]:
				Enums.TARGET_SHAPE.CIRCLE:
					if hoveringOver != null:
						drawCircle(hoveringOver.global_position, targetDetails[1], Color("#fc030364"))

func drawLine(startPos: Vector3, endPos: Vector3, color: Color) -> void:
	var meshInstance = MeshInstance3D.new()
	var immediateMesh = ImmediateMesh.new()
	
	meshInstance.mesh = immediateMesh
	meshInstance.cast_shadow = false
	
	immediateMesh.surface_begin(Mesh.PRIMITIVE_LINES, createMeshMaterial(color))
	immediateMesh.surface_add_vertex(startPos)
	immediateMesh.surface_add_vertex(endPos)
	immediateMesh.surface_end()
	
	drawnMeshes.append(meshInstance)
	add_child(meshInstance)

func drawLine2(startPos: Vector3, endPos: Vector3, color: Color) -> void:
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
	var mainActors = actors
	mainActors.append(hoveringOver)
	for area in areas:
		var overlap = area.get_overlapping_areas()
		for actor in overlap:
			if actor not in mainActors:
				overlappingEnemies.append(actor)
	return overlappingEnemies

func setTargetMode(type: Enums.TARGET_TYPE, actorPositions: Array, additionalTargetDetails: Array):
	currentTargetingMode = type
	actors = actorPositions
	if additionalTargetDetails.size() > 0: targetDetails = additionalTargetDetails

func addTarget(_actor):
	var allTargets = [hoveringOver]
	allTargets.append_array(checkOverlappingAreas())
	
	var s = emit_signal("targetingComplete", allTargets)
	
	if s != OK:
		Global.printSignalError("TargetUI", "addTarget", "targetingComplete")

func consideredTarget(actor):
	hoveringOver = actor
	draw()

func noLongerConsideredTarget():
	hoveringOver = null
	clear()
	draw()

func end():
	currentTargetingMode = Enums.TARGET_TYPE.NONE
	actors = []
	hoveringOver = null
	targetDetails = []
	clear()
	Global.set_player_targeting(false)
	draw()

func clear():
	for mesh in drawnMeshes:
		mesh.queue_free()
	drawnMeshes = []
	
	for area in areas:
		area.queue_free()
	areas = []
