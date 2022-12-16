extends Control

signal whatDo(command, partner)

@onready var attack := $"%Attack"
@onready var defend := $"%Defend"
@onready var special := $"%Special"
@onready var run := $"%Run"
@onready var extendedMenu = $"%ExtendedMenu"

var showExtendedMenu = false

func _ready():
	set_process_unhandled_input(true)

func _process(_delta):
	if showExtendedMenu:
		extendedMenu.visible = true
	else:
		extendedMenu.visible = false

func _on_attack_pressed():
	var s = emit_signal("whatDo", GenericCommands.ATTACK, null)
	if s != OK:
		Global.printSignalError("CommandMenu", "_on_attack_pressed", "whatDo")

func _on_defend_pressed():
	var s = emit_signal("whatDo", GenericCommands.DEFEND, null)
	if s != OK:
		Global.printSignalError("CommandMenu", "_on_defend_pressed", "whatDo")

func _on_skills_pressed():
	# Brings up the ExtendedMenu to show skills
	showExtendedMenu = true

func _on_special_pressed():
	# Bring up a character-unique interface...
	pass

func _on_run_pressed():
	var s = emit_signal("whatDo", GenericCommands.RUN, null)
	if s != OK:
		Global.printSignalError("CommandMenu", "_on_run_pressed", "whatDo")

func setPosition(coordinates: Vector2):
	position = coordinates

func setButtons(characterType):
	showExtendedMenu = false
	match characterType:
		Enums.CHARACTER.ARAVIX:
			special.text = "Alchemy"
		Enums.CHARACTER.AYLIK:
			special.text = "Taming"
		Enums.CHARACTER.TASTY:
			special.text = "Magic"

func setExtendedMenuCommands(slot):
	var partyMem = Global.get_party_member_by_slot(slot)
	extendedMenu.clear()
	extendedMenu.populate(partyMem)

func _unhandled_input(event):
	if event is InputEventMouseButton && event.pressed && event.button_index == MOUSE_BUTTON_LEFT \
		or event.is_action_pressed("ui_select"):
			hide()
			showExtendedMenu = false


func extendedCommandSelected(command, partner):
	var s = emit_signal("whatDo", command, partner)
	if s != OK:
		Global.printSignalError("CommandMenu", "extendedCommandSelected", "whatDo")
