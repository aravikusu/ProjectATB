extends Control

@onready var slot1 = $"%Frame1"
@onready var slot2 = $"%Frame2"
@onready var slot3 = $"%Frame3"

var showingCommandsForSlot = 0

func fillData(slot, partyMember):
	var frame
	match slot:
		0: frame = slot1
		1: frame = slot2
		2: frame = slot3
	frame.setup(partyMember)

func clearParty():
	slot1.clear()
	slot2.clear()
	slot3.clear()
