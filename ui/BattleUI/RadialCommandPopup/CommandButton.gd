@tool
extends Control

@onready var commandText = $"%CommandText"
@onready var icon = $"%Button"
@onready var description = $"%Description"

@export_enum("Attack", "Defend", "Skill", "Item", "Run", "Pass", "Alchemy", "Taming", "Magic") var command:
	set(newCommand):
		command = newCommand

@export_enum("X", "Triangle", "Circle", "Square") var button:
	set(newButton):
		button = newButton

# Called when the node enters the scene tree for the first time.
func _ready():
	setup()

func _process(_delta):
	if Engine.is_editor_hint():
		setup()

func setup():
	match command:
		0:
			commandText.text = "Attack"
			description.text = "Basic attack"
		1:
			commandText.text = "Defend"
			description.text = "Defend for a turn"
		2:
			commandText.text = "Skill"
			description.text = "Use a skill"
		3:
			commandText.text = "Item"
			description.text = "Use an item"
		4:
			commandText.text = "Run"
			description.text = "Attempt to run"
		5:
			commandText.text = "Pass"
			description.text = "Pass to the next in line"
	
	match button:
		0:
			icon.texture = load("res://assets/ui/button-cross.png")
		1:
			icon.texture = load("res://assets/ui/button-triangle.png")
		2:
			icon.texture = load("res://assets/ui/button-circle.png")
		3:
			icon.texture = load("res://assets/ui/button-square.png")

func setSpecialButton(characterType: Enums.CHARACTER):
	match characterType:
		Enums.CHARACTER.ARAVIX:
			commandText.text = "Alchemy"
			description.text = "Create concoctions"
		Enums.CHARACTER.AYLIK:
			commandText.text = "Taming"
			description.text = "Command your monsters"
		Enums.CHARACTER.TASTY:
			commandText.text = "Magic"
			description.text = "Summon the elements"
