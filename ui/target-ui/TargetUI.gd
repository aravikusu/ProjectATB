extends Control

signal targetingComplete(targets)

var currentTargetingMode = Enums.TARGET_TYPE.NONE
var actors = []
var hoveringOver = null
var targetDetails = []
var areas = []

# Called every frame. 'delta' is the elapsed time since the previous frame.
@onready var canvas = $CanvasLayer
func _process(_delta):
	if Global.BATTLE_TARGETING_MODE:
		canvas.visible = true
	else:
		canvas.visible = false

func _draw():
	match currentTargetingMode:
		Enums.TARGET_TYPE.LINE:
			# Draw a line from the actors to the target.
			# Any overlapping enemies should also be hit...
			if hoveringOver != null:
				for actor in actors:
					var start = actor.global_position
					var endPos = hoveringOver.global_position
					draw_line(start, endPos, Color("#fc030364"), 2, true)
					createArea("line", { 
						"start": start,
						"end": endPos
					})
		Enums.TARGET_TYPE.SHAPE:
			# There can be multiple shapes... for now there is only Circle, though.
			match targetDetails[0]:
				Enums.TARGET_SHAPE.CIRCLE:
					if hoveringOver != null:
						draw_circle(hoveringOver.global_position, targetDetails[1], Color("#fc030364"))
						createArea("circle", {
							"position": hoveringOver.global_position,
							"radius": targetDetails[1]
						})

func createArea(shape: String, deets: Dictionary):
	var area = Area2D.new()
	var collision = CollisionShape2D.new()
	var collisionShape
	
	# Setting collision by code is LAME
	# pls
	area.set_collision_layer_value(1, false)
	area.set_collision_layer_value(4, true)
	
	area.set_collision_mask_value(1, false)
	area.set_collision_mask_value(3, true)
	area.set_collision_mask_value(2, true)
	match shape:
		"line":
			collisionShape = SegmentShape2D.new()
			collisionShape.a = deets.start
			collisionShape.b = deets.end
		"circle":
			collisionShape = CircleShape2D.new()
			collisionShape.radius = deets.radius
			area.global_position = deets.position
	
	collision.shape = collisionShape
	add_child(area)
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
	queue_redraw()

func noLongerConsideredTarget():
	hoveringOver = null
	clearAreas()
	queue_redraw()

func end():
	currentTargetingMode = Enums.TARGET_TYPE.NONE
	actors = []
	hoveringOver = null
	targetDetails = []
	clearAreas()
	Global.set_player_targeting(false)
	queue_redraw()

func clearAreas():
	for area in areas:
		area.queue_free()
	areas = []
