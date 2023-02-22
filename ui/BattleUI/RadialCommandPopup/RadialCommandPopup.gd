extends Control

signal whatDo(command, partner, isItem)
signal passTurn(slot)

@onready var radial = $"%MainRadial"
@onready var extendedMenu = $"%ExtendedMenu"
@onready var special = $"%Special"
@onready var BG = $"%BG"

var slot: int
var canAct = false
var showExtendedMenu = false

func handleInputs():
	if canAct && !showExtendedMenu:
		if Input.is_action_just_pressed("battle_attack"):
			actionize(GenericCommands.ATTACK)
		if Input.is_action_just_pressed("battle_skill"):
			populateExtendedMenu("skill")
		if Input.is_action_just_pressed("battle_item"):
			populateExtendedMenu("item")
		if Input.is_action_just_pressed("battle_special"):
			pass
		if Input.is_action_just_pressed("battle_run"):
			actionize(GenericCommands.RUN)
		if Input.is_action_just_pressed("battle_defend"):
			actionize(GenericCommands.DEFEND)
		if Input.is_action_just_pressed("battle_pass"):
			canAct = false
			var s = emit_signal("passTurn", slot)
			if s != OK:
				Global.printSignalError("RadialCommandPopup", "handleInputs", "passTurn")

func _process(_delta):
	handleInputs()
	
	if showExtendedMenu:
		extendedMenu.visible = true
		radial.visible = false
	else:
		extendedMenu.visible = false
		radial.visible = true

func populateExtendedMenu(type: String):
	extendedMenu.clear()
	radial.hide()
	await get_tree().create_timer(0.1).timeout
	var partyMem = Global.get_party_member_by_slot(slot)
	match type:
		"skill":
			extendedMenu.populateSkill(partyMem)
		"item":
			extendedMenu.populateItem(partyMem)
	showExtendedMenu = true

# Player exited out of the extended menu
func hideExtendedMenu():
	print("yes")
	showExtendedMenu = false
	radial.show()

func setup(partyMemSlot: int):
	canAct = true
	showExtendedMenu = false
	slot = partyMemSlot
	var partyMem = Global.get_party_member_by_slot(slot)
	
	#position = get_viewport().get_camera_3d().unproject_position(partyMem.global_transform.origin)
	special.setSpecialButton(partyMem.characterType)
	setColor(partyMem.characterType)
	show()

func setColor(characterType):
	match characterType:
		Enums.CHARACTER.ARAVIX:
			BG.modulate = Color("#446abd")
		Enums.CHARACTER.AYLIK:
			BG.modulate = Color("#218251")
		Enums.CHARACTER.TASTY:
			BG.modulate = Color("#ba7ca7")

func actionize(command: Dictionary, partner : Object = null, isItem: bool = false):
	hide()
	canAct = false
	var s = emit_signal("whatDo", slot, command, partner, isItem)
	if s != OK:
		Global.printSignalError("RadialCommandPopup", "actionize", "whatDo")
