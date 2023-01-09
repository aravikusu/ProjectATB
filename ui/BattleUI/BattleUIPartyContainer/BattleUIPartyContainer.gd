extends Control

@onready var slot1 = $HBoxContainer/VBoxContainer/BattleUIPartyMember
@onready var slot2 = $HBoxContainer/VBoxContainer/BattleUIPartyMember2
@onready var slot3 = $HBoxContainer/VBoxContainer/BattleUIPartyMember3
@onready var stupidSpacer = $HBoxContainer/VBoxContainer/spacer

var showingCommandsForSlot = 0

func fillData(slot, partyMember):
	var frame
	match slot:
		0: frame = slot1
		1: frame = slot2
		2: frame = slot3
	frame.fillData(partyMember)

func _process(_delta):
	stupidSpacer.custom_minimum_size = Vector2(0, get_viewport_rect().size.y / 5)

func clearParty():
	slot1.clear()
	slot2.clear()
	slot3.clear()
