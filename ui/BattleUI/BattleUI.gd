extends Control

signal sendCommand(slot, command, partner)

@onready var player = $AnimationPlayer
@onready var notification = $CanvasLayer/BattleNotification
@onready var partyContainer = $CanvasLayer/BattleUIPartyContainer
@onready var multihit = $CanvasLayer/MultihitDamageCounter
@onready var radialCommandPopup = $CanvasLayer/RadialCommandPopup

var radialMenuVisible = false

func _ready():
	multihit.position = Vector2(get_viewport_rect().size.x, get_viewport_rect().size.y / 4)
	radialCommandPopup.hide()

func startBattle():
	player.play("shockwave")

func end():
	player.play("end")

func clearPartyUI():
	partyContainer.clearParty()

func showNotification(message: String, actor = ""):
	notification.showMessage(message, actor)

func showTargetNotification(message):
	notification.targetMessage(message)

func unstickNotification():
	notification.unstickNotification()

func fillPartyData(slot, partyMember):
	partyContainer.fillData(slot, partyMember)

func commandTime(slot, command, partner):
	var s = emit_signal("sendCommand", slot, command, partner)
	
	if s != OK:
		Global.printSignalError("BattleUI", "commandTime", "sendCommand")

func showMultihit(hits: int, damage: int):
	multihit.prepare(hits, damage)

func showRadialMenu(slot: int):
	radialMenuVisible = true
	radialCommandPopup.setup(slot)

func hideRadialMenu():
	radialMenuVisible = false

func reappearRadialMenu():
	radialCommandPopup.show()
	await get_tree().create_timer(0.1).timeout
	radialCommandPopup.canAct = true

func passTurn():
	pass
