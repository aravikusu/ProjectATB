@tool
extends PanelContainer

const activeColor = Color("#00000064")
const inactiveColor = Color("00000000")

@export var active = false

@export var text = "":
	set(newText):
		text = newText

@onready var textLabel = $"%Text"

@onready var activeLabelSettings = preload("res://ui/CampsiteMenu/active-button.tres")
@onready var inactiveLabelSettings = preload("res://ui/CampsiteMenu/inactive-button.tres")
func _ready():
	textLabel.text = text

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Engine.is_editor_hint():
		textLabel.text = text
	
	if active:
		add_theme_color_override("bg_color", activeColor)
		textLabel.label_settings = activeLabelSettings
	else:
		add_theme_color_override("bg_color", inactiveColor)
		textLabel.label_settings = inactiveLabelSettings

func activate():
	active = true

func inactivate():
	active = false
