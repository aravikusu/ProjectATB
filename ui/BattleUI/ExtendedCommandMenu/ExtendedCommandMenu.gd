extends MarginContainer

signal selected(command, partner)

var allItems = []

@onready var grid = $"%Grid"
@onready var extendedCommand = preload("res://ui/BattleUI/ExtendedCommand/ExtendedCommand.tscn")

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
		instance.connect("selected", Callable(self, "sendSelectedSignal"))
		allItems.append(command)

func clear():
	get_tree().call_group("extendedcommand", "queue_free")
	allItems.clear()

func sendSelectedSignal(command, partner):
	var s = emit_signal("selected", command, partner)
	if s != OK:
		Global.printSignalError("ExtendedCommandMenu", "sendSelectedSignal", "selected")
