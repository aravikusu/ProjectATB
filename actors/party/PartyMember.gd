extends CharacterBody3D

signal targetedForAction(node)
signal consideredTarget(node)
signal noLongerConsideredTarget()

var speed := 3.0
var gravity := 2.0

var _velocity := Vector3.ZERO

var loadedCharacter = {}
var characterType = Enums.CHARACTER.NONE
var displayName = "Test"
var playerControlled = true
var forcedToMove = false
var forceMoveTarget = Vector3(0, 0, 0)

var active = true

var maxHP = 100
var currentHP = 100
var maxMP = 100
var currentMP = 100
var ATB = 0
var stats = {}
var commands = []
var CHARACTER_BATTLE_STATE = Enums.CHARACTER_BATTLE_STATE.CHARGING
var currentSprite = "overworld"

var showOutline = false

@export var partyLeader = false
@export_node_path(CharacterBody3D) var target

@onready var spriteViewport = $SpriteViewport
@onready var navigationAgent = $NavigationAgent3D
@onready var camera = $"%Camera"

func handle_input() -> Vector3:
	var input = Vector3()
	
	if Input.is_action_pressed("movement_up"):
		input.z -= 1
	if Input.is_action_pressed("movement_down"):
		input.z += 1
	if Input.is_action_pressed("movement_left"):
		input.x -= 1
	if Input.is_action_pressed("movement_right"):
		input.x += 1
	
	return input

func _ready():
	if partyLeader:
		camera.current = true

func _physics_process(delta):
	if forcedToMove:
		if (delta * speed) > position.distance_to(forceMoveTarget):
			forcedToMove = false
			speed = position.distance_to(forceMoveTarget) / delta
		set_velocity((forceMoveTarget - global_position).normalized() * speed)
		move_and_slide()
	else:
		if Global.get_game_state() == Enums.GAME_STATE.ROAMING:
			if partyLeader:
				# Party leader. Is controller by the player.
				if Global.get_game_state() == Enums.GAME_STATE.ROAMING:
					_velocity.x = 0
					_velocity.z = 0
					var input = handle_input()
					input = input.normalized()
					#var direction = (transform.basis.z * input.z + transform.basis.x * input.x)
					
					_velocity.x = input.x * speed
					_velocity.z = input.z * speed
					
					if not is_on_floor():
						_velocity.y -= gravity * delta
					
					set_velocity(_velocity)
					@warning_ignore(return_value_discarded)
					move_and_slide()
			else:
				# A follower. Always follows their target.
				var moveDirection = position.direction_to(navigationAgent.get_next_location())
				_velocity = moveDirection * speed
				look_at(moveDirection)

func setTargetLocation(targetLocation: Vector3):
	navigationAgent.set_target_location(targetLocation)

func swapCharacter(player):
	var character
	match player.type:
		Enums.CHARACTER.ARAVIX:
			character = load("res://actors/party/Aravix.tscn")
		Enums.CHARACTER.TASTY:
			character = load("res://actors/party/Tasty.tscn")
		Enums.CHARACTER.AYLIK: 
			character = load("res://actors/party/Aylik.tscn")
		_:
			character = load("res://actors/party/Aravix.tscn")
	# Remove the old character if it exists, then save the new one
	if loadedCharacter != {}:
		loadedCharacter.queue_free()
	var instance = character.instantiate()
	spriteViewport.add_child(instance)
	loadedCharacter = instance
	
	characterType = player.type
	stats = PartyHelper.getPartyMemberStats(player.level, player.type)
	maxHP = stats.HP
	maxMP = stats.MP
	currentHP = player.currentHP
	currentMP = player.currentMP
	displayName = player.name
	commands = PartyHelper.getPartyMemberCommands(player)

func postBattleClean():
	ATB = 0
	CHARACTER_BATTLE_STATE = Enums.CHARACTER_BATTLE_STATE.CHARGING
	setOverworldSprite()

func flush():
	loadedCharacter.queue_free()
	loadedCharacter = {}
	characterType = Enums.CHARACTER.NONE
	CHARACTER_BATTLE_STATE = Enums.CHARACTER_BATTLE_STATE.CHARGING
	stats = {}
	commands = []
	currentSprite = "overworld"
	ATB = 0

# Forcefully move the actor to a set location.
# Used in cutscenes, combat, etc.
func forceMove(location):
	forcedToMove = true
	forceMoveTarget = location

# Wildcard - set any sprite.
func setSprite(sprite: String):
	loadedCharacter.changeSprite(sprite)

func setOverworldSprite():
	if currentSprite != "overworld":
		currentSprite = "overworld"
		loadedCharacter.changeSprite("overworld")

func setReadySprite():
	if currentSprite != "ready":
		currentSprite = "ready"
		loadedCharacter.changeSprite("ready")

func setDeadSprite():
	if currentSprite != "dead":
		currentSprite = "dead"
		loadedCharacter.changeSprite("dead")

func playDeadAnimation():
	setDeadSprite()

func clicked():
	if CHARACTER_BATTLE_STATE != Enums.CHARACTER_BATTLE_STATE.DEAD:
		if Global.BATTLE_TARGETING_MODE:
			var s = emit_signal("targetedForAction", self)
			if s != OK:
				Global.printSignalError("PartyMember", "clicked", "targetedForAction")

func hover():
	if CHARACTER_BATTLE_STATE != Enums.CHARACTER_BATTLE_STATE.DEAD:
		if Global.BATTLE_TARGETING_MODE && !showOutline:
			showOutline = true
			loadedCharacter.showOutline()
			var s = emit_signal("consideredTarget", self)
			if s != OK:
				Global.printSignalError("PartyMember", "hover", "consideredTarget")

func unhover():
	if CHARACTER_BATTLE_STATE != Enums.CHARACTER_BATTLE_STATE.DEAD:
		if showOutline:
			showOutline = false
			loadedCharacter.hideOutline()
			var s = emit_signal("noLongerConsideredTarget")
			if s != OK:
				Global.printSignalError("PartyMember", "unhover", "noLongerConsideredTarget")
