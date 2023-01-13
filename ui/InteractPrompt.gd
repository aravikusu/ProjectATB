@tool
extends Node3D

@export_enum("Cross", "Square", "Triangle", "Circle") var icon:
	set(newIcon):
		icon = newIcon
@export var text = "Text":
	set(newText):
		text = newText

@onready var button = $"%Button"
@onready var textLabel = $"%Text"

func _ready():
	setup()

func _process(_delta):
	if Engine.is_editor_hint():
		setup()

func setup():
	var textCharacters = text.length()
	var offset = 0
	
	if textCharacters > 4:
		offset = 8 * (textCharacters - 4)
	
	textLabel.text = text
	textLabel.offset = Vector2(offset, 0)
	match icon:
		0:
			button.texture = load("res://assets/ui/button-cross.png")
		1:
			button.texture = load("res://assets/ui/button-square.png")
		2:
			button.texture = load("res://assets/ui/button-triangle.png")
		3:
			button.texture = load("res://assets/ui/button-circle.png")
