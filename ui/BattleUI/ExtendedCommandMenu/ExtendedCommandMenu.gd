extends MarginContainer

signal selected(command, partner)
signal cancel

var allItems = []
var currentIndex = 0

var active = false

@onready var grid = $"%Grid"
@onready var extendedCommand = preload("res://ui/BattleUI/ExtendedCommand/ExtendedCommand.tscn")

func handleInputs():
	if active:
		if Input.is_action_just_pressed("ui_select"):
			if !allItems[currentIndex].disabled:
				select(allItems[currentIndex])
		if Input.is_action_just_pressed("ui_cancel"):
			active = false
			
			var s = emit_signal("cancel")
			if s != OK:
				Global.printSignalError("ExtendedCommandMenu", "handleInputs", "cancel")
		if Input.is_action_just_pressed("ui_down"):
			if currentIndex + 1 >= allItems.size():
				currentIndex = allItems.size() - 1
			else:
				currentIndex += 1
		if Input.is_action_just_pressed("ui_up"):
			if currentIndex - 1 < 0:
				currentIndex = 0
			else:
				currentIndex -= 1

func _process(_delta):
	if active:
		handleInputs()
		for item in allItems:
			item.unhighlight()
		allItems[currentIndex].highlight()

func populate(partyMem) -> void:
	for command in partyMem.commands:
		var instance = extendedCommand.instantiate()
		grid.add_child(instance)
		
		var description = ""
		
		match command.multitech:
			Enums.MULTITECH_TYPE.ARA_AYL:
				description += "DUAL TECH: ARAVIX & AYLIK.\n"
			Enums.MULTITECH_TYPE.ARA_TAS:
				description += "DUAL TECH: ARAVIX & TASTY.\n"
			Enums.MULTITECH_TYPE.AYL_TAS:
				description += "DUAL TECH: AYLIK & TASTY.\n"
			Enums.MULTITECH_TYPE.TRIPLE:
				description += "TRIPLE TECH.\n"
		description += command.description
		instance.prepare(partyMem, command, description)
		allItems.append(instance)
	active = true

func clear():
	get_tree().call_group("extendedcommand", "queue_free")
	allItems.clear()
	currentIndex = 0

func select(command):
	active = false
	var s = emit_signal("selected", command.skill, command.partner)
	if s != OK:
		Global.printSignalError("ExtendedCommandMenu", "select", "selected")
