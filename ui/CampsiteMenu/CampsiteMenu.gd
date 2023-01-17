extends MarginContainer

var menuActive = false
var menuIndex = 0

var buttons = []
@onready var restButton = $"%Rest"
@onready var chatButton = $"%Chat"
@onready var saveButton = $"%Save"

# Called when the node enters the scene tree for the first time.
func _ready():
	buttons.append_array([restButton, chatButton, saveButton])

func handleInputs():
	if menuActive:
		if Input.is_action_just_pressed("ui_down"):
			buttons[menuIndex].inactivate()
			if menuIndex + 1 >= buttons.size():
				menuIndex = 0
			else:
				menuIndex += 1
		if Input.is_action_just_pressed("ui_up"):
			buttons[menuIndex].inactivate()
			if menuIndex - 1 < 0:
				menuIndex = buttons.size() - 1
			else:
				menuIndex -= 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	handleInputs()
	buttons[menuIndex].activate()

func activate():
	menuActive = true

func disable():
	menuActive = false
