extends Area2D

signal targetedForAction(actor)
signal consideredTarget(actor)
signal noLongerConsideredTarget()

# Used to store get the actual stats and abilities of said enemy.
@export var displayName := ""
var playerControlled = false

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
@onready var sprite = $AnimatedSprite2D

func _ready():
	stats = EnemyHelper.getEnemyStats(displayName)
	commands = EnemyHelper.getEnemyCommands(displayName)

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

func _on_mouse_entered():
	if CHARACTER_BATTLE_STATE != Enums.CHARACTER_BATTLE_STATE.DEAD:
		if Global.BATTLE_TARGETING_MODE && !showOutline:
			showOutline = true
			player.play("outline")
			var s = emit_signal("consideredTarget", self)
			if s != OK:
				Global.printSignalError("Enemy", "_on_mouse_entered", "consideredTarget")

func _on_mouse_exited():
	if CHARACTER_BATTLE_STATE != Enums.CHARACTER_BATTLE_STATE.DEAD:
		if showOutline:
			showOutline = false
			player.play_backwards("outline")
			var s = emit_signal("noLongerConsideredTarget")
			if s != OK:
				Global.printSignalError("Enemy", "_on_mouse_exited", "noLongerConsideredTarget")

func _on_input_event(_viewport, event, _shape_idx):
	if CHARACTER_BATTLE_STATE != Enums.CHARACTER_BATTLE_STATE.DEAD:
		if Global.BATTLE_TARGETING_MODE:
			if (event is InputEventMouseButton && event.pressed && event.button_index == MOUSE_BUTTON_LEFT) \
			or (event.is_action_pressed("ui_select")):
				var s = emit_signal("targetedForAction", self)
				if s != OK:
					Global.printSignalError("Enemy", "_on_input_event", "targetedForAction")
