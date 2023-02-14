extends CharacterBody3D

var speed := 3.0
var gravity := 2.0

var _velocity := Vector3.ZERO

var loadedCharacter = {}
var characterType = Enums.CHARACTER.NONE
var displayName = "Test"
var playerControlled = true
var forcedToMove = false
var forceMoveTarget = Vector3(0, 0, 0)
var forceMoveSpeed = 0

# Follower specific
var didArrive = false
var targetLocation = Vector3.ZERO
var moveDirection = Vector3.ZERO
var moveDelta: float

var ATB = 0
@export var stats: Stats
var commands = []
var CHARACTER_BATTLE_STATE = Enums.CHARACTER_BATTLE_STATE.CHARGING
var currentSprite = "overworld"
var hitboxRadius = 0

var showOutline = false

var active = true

@export var partyLeader = false
@export var target: CharacterBody3D

@onready var characterAnchor = $CharacterAnchor
@onready var navigationAgent = $NavigationAgent3D
@onready var camera = $"%Camera"
@onready var selector = $ActorSelector
@onready var highlight = $ActorHighlight

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
	hitboxRadius = $CollisionShape3D.shape.radius
	if partyLeader:
		camera.current = true

var test = false
func _physics_process(delta):
	if forcedToMove:
		if (delta * forceMoveSpeed) > position.distance_to(forceMoveTarget):
			forcedToMove = false
			forceMoveSpeed = position.distance_to(forceMoveTarget) / delta
		set_velocity((forceMoveTarget - global_position).normalized() * forceMoveSpeed)
		move_and_slide()
	else:
		if Global.get_game_state() == Enums.GAME_STATE.ROAMING:
			if partyLeader:
				# Party leader. Is controller by the player.
				_velocity.x = 0
				_velocity.z = 0
				var input = handle_input()
				input = input.normalized()
				
				_velocity.x = input.x * speed
				_velocity.z = input.z * speed
				
				if not is_on_floor():
					_velocity.y -= gravity * delta
				
				set_velocity(_velocity)
				move_and_slide()
			else:
				# A follower. Always follows their target.
				setTargetPosition(target.global_position)
				moveDelta = speed * delta
				var current = global_transform.origin
				var next = navigationAgent.get_next_path_position()
				_velocity = (next - current) * speed
				
				if not is_on_floor():
					_velocity.y -= gravity * delta
				
				set_velocity(_velocity)
				move_and_slide()

# Used in follower mode. Sets the current position of their target.
func setTargetPosition(pos: Vector3):
	didArrive = false
	navigationAgent.set_target_position(pos)

func swapCharacter(player):
	var character
	match player.type:
		Enums.CHARACTER.ARAVIX:
			character = load("res://actors/party/Aravix.tscn")
			selector.color = Color("#446abd")
			highlight.color = Color("#446abd")
		Enums.CHARACTER.TASTY:
			character = load("res://actors/party/Tasty.tscn")
			selector.color = Color("#ba7ca7")
			highlight.color = Color("#ba7ca7")
		Enums.CHARACTER.AYLIK: 
			character = load("res://actors/party/Aylik.tscn")
			selector.color = Color("#218251")
			highlight.color = Color("#218251")
		Enums.CHARACTER.MONSTER:
			character = load("res://actors/party/monsters/Dummy.tscn")
			selector.color = Color("#774b2c")
			highlight.color = Color("#774b2c")
	
	# Remove the old character if it exists, then save the new one
	if loadedCharacter != {}:
		loadedCharacter.queue_free()
	var instance = character.instantiate()
	characterAnchor.add_child(instance)
	loadedCharacter = instance
	
	characterType = player.type
	stats = PartyHelper.getPartyMemberStats(player.level, player.type)
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
	stats = null
	commands = []
	currentSprite = "overworld"
	ATB = 0

func toggleCurrentBattleActor():
	selector.visible = !selector.visible
	highlight.visible = !highlight.visible

# Forcefully move the actor to a set location.
# Used in cutscenes, combat, etc.
func forceMove(location: Vector3, fSpeed: int = 3):
	forcedToMove = true
	forceMoveTarget = location
	forceMoveSpeed = fSpeed

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

func getHeight():
	return loadedCharacter.getHeight()

func playDeadAnimation():
	setDeadSprite()

func setInactive():
	set_collision_layer_value(2, false)
