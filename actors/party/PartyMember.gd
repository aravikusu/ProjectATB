extends Node3D

signal targetedForAction(node)
signal consideredTarget(node)
signal noLongerConsideredTarget()

# A script shared between party members, used for their AnimatedSprite,
# which is in turn used in Player and PartyTrain

var loadedCharacter = {}
var characterType = Enums.CHARACTER.NONE
var displayName = "Test"
var playerControlled = true

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

@export var moveDelay = 20

@onready var spriteViewport = $SpriteViewport
func _process(_delta):
	# Party members should only follow the leader if we're not in an event.
	if Global.get_game_state() == Enums.GAME_STATE.ROAMING:
		if Global.partyArray[moveDelay] != null:
			self.global_position = Global.partyArray[moveDelay]

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

# Used in cutscenes and combat to move the
func moveToLocation(location: Vector3, speed: float = 1.0):
	var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "global_position", location, speed)

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
