extends Control

signal sendCommand(slot, command, partner)

@onready var slot1 = $HBoxContainer/VBoxContainer/BattleUIPartyMember
@onready var slot2 = $HBoxContainer/VBoxContainer/BattleUIPartyMember2
@onready var slot3 = $HBoxContainer/VBoxContainer/BattleUIPartyMember3
@onready var stupidSpacer = $HBoxContainer/VBoxContainer/spacer
@onready var commandMenu = $CommandMenu

var showingCommandsForSlot = 0

func _ready():
	commandMenu.hide()

func fillData(slot, partyMember):
	var frame
	match slot:
		0: frame = slot1
		1: frame = slot2
		2: frame = slot3
	frame.fillData(partyMember)

func _process(_delta):
	stupidSpacer.custom_minimum_size = Vector2(0, get_viewport_rect().size.y / 5) 

func showCommandMenu(slot, partyMemberType):
	commandMenu.show()
	var partyMemSlot
	match slot:
		1:
			partyMemSlot = slot1
			showingCommandsForSlot = 1
		2:
			partyMemSlot = slot2
			showingCommandsForSlot = 2
		3:
			partyMemSlot = slot3
			showingCommandsForSlot = 3
	commandMenu.setPosition(Vector2(partyMemSlot.position.x + 170, partyMemSlot.position.y))
	commandMenu.setButtons(partyMemberType)
	commandMenu.setExtendedMenuCommands(slot)

func timeToAct(command, partner):
	var s = emit_signal("sendCommand", showingCommandsForSlot, command, partner)
	if s != OK:
		Global.printSignalError("BattleUIPartyContainer", "_on_gui_input", "sendCommand")
	commandMenu.hide()

func hideCommandMenu():
	commandMenu.hide()

func clearParty():
	slot1.clear()
	slot2.clear()
	slot3.clear()
