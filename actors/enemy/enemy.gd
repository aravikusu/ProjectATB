extends CharacterBody3D

signal targetedForAction(actor)
signal consideredTarget(actor)
signal noLongerConsideredTarget()

# Used to store get the actual stats and abilities of said enemy.
@export var displayName := ""
var playerControlled = false
var forcedToMove = false
var forceMoveTarget = Vector3(0, 0, 0)

var speed := 3.0
var gravity := 2.0

var stats = {}
var commands = []
var maxHP = 100
var currentHP = 100
var maxMP = 100
var currentMP = 100
var ATB = 0
var CHARACTER_BATTLE_STATE = Enums.CHARACTER_BATTLE_STATE.CHARGING
var currentSprite = "overworld"

var showOutline = false

@onready var player = $AnimationPlayer
@onready var sprite = $"%Sprite"

func _ready():
	stats = EnemyHelper.getEnemyStats(displayName)
	commands = EnemyHelper.getEnemyCommands(displayName)

func _physics_process(delta):
	if forcedToMove:
		if (delta * speed) > position.distance_to(forceMoveTarget):
			forcedToMove = false
			speed = position.distance_to(forceMoveTarget) / delta
		set_velocity((forceMoveTarget - global_position).normalized() * speed)
		move_and_slide()

func setOverworldSprite():
	if currentSprite != "overworld":
		currentSprite = "overworld"
		sprite.animation = "overworld"

func setReadySprite():
	if currentSprite != "ready":
		currentSprite = "ready"
		sprite.animation = "ready"

func setDeadSprite():
	if currentSprite != "dead":
		currentSprite = "dead"
		sprite.animation = "dead"

# All actors have their own dead animation... play it
func playDeadAnimation():
	player.play("dead")

func forceMove(location):
	forcedToMove = true
	forceMoveTarget = location

func hover():
	if CHARACTER_BATTLE_STATE != Enums.CHARACTER_BATTLE_STATE.DEAD:
		if Global.BATTLE_TARGETING_MODE && !showOutline:
			showOutline = true
			player.play("outline")
			var s = emit_signal("consideredTarget", self)
			if s != OK:
				Global.printSignalError("Enemy", "hover", "consideredTarget")

func unhover():
	if CHARACTER_BATTLE_STATE != Enums.CHARACTER_BATTLE_STATE.DEAD:
		if showOutline:
			showOutline = false
			player.play_backwards("outline")
			var s = emit_signal("noLongerConsideredTarget")
			if s != OK:
				Global.printSignalError("Enemy", "unhover", "noLongerConsideredTarget")

func clicked():
	if CHARACTER_BATTLE_STATE != Enums.CHARACTER_BATTLE_STATE.DEAD:
		if Global.BATTLE_TARGETING_MODE:
			var s = emit_signal("targetedForAction", self)
			if s != OK:
				Global.printSignalError("Enemy", "clicked", "targetedForAction")
