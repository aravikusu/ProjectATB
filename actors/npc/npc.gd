@tool
extends CharacterBody3D

## Determines what NPC we put in here.
@export var npcKey = "":
	set(newKey):
		npcKey = newKey

## The actual name that appears in text boxes.
@export var displayName = ""
## The expected event when talking to this NPC.[br]
## Note that a text box will appear for both options if dialogue is supplied,
## the shop will simply open after the dialogue is finished.
@export_enum("Talk", "Shop") var interactType

## The text that appears on the InteractPrompt.
@export var labelText = "":
	set(newText):
		labelText = newText

## Should the NPC move or not?
@export var isStationary = true

## If the NPC should move, connect a path it should follow.
@export_node_path("Path3D") var path
var pathPoints
var patrolIndex = 0

## Walking speed of the NPC.
@export var SPEED = 3.0

var connectedSprite = null
var _velocity = Vector3.ZERO
var inrange = false

@onready var interactPrompt = $InteractPrompt
@onready var spriteAnchor = $SpriteAnchor
func _ready():
	if !Engine.is_editor_hint():
		setStuff()
		if !isStationary:
			pathPoints = get_node(path).curve.get_baked_points()

func handleInputs():
	if Global.get_game_state() == Enums.GAME_STATE.ROAMING:
		if inrange:
			if Input.is_action_just_pressed("ui_select"):
				interact()

func interact():
	inrange = false

func _physics_process(delta):
	if Engine.is_editor_hint():
		pass
	else:
		handleInputs()
		
		if inrange:
			interactPrompt.visible = true
		else:
			interactPrompt.visible = false
		
		if isStationary:
			pass
		else:
			var target = pathPoints[patrolIndex]
			if position.distance_to(target) < 0.3:
				patrolIndex = wrapi(patrolIndex + 0.01, 0, pathPoints.size())
				target = pathPoints[patrolIndex]
			_velocity = (target - position).normalized() * SPEED
		
		if not is_on_floor():
			_velocity.y -= 2.0 * delta
		
		set_velocity(_velocity)
		move_and_slide()

func setStuff():
	var newSprite = load("res://actors/npc/" + npcKey + ".tscn").instantiate()
	
	spriteAnchor.add_child(newSprite)
	connectedSprite = newSprite
	interactPrompt.text = labelText
	interactPrompt.setup()

func _on_interact_area_body_entered(body):
	if body == Global.get_player_character():
		inrange = true


func _on_interact_area_body_exited(body):
	if body == Global.get_player_character():
		inrange = false
