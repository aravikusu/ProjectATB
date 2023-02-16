extends TextureRect

@export var inputName = ""

var kbm = true

var controllerButton
var keyboardButton
# Called when the node enters the scene tree for the first time.
func _ready():
	var input =  InputMap.action_get_events(inputName)
	
	for event in input:
		if event is InputEventJoypadButton:
			controllerButton = load("res://assets/ui/buttons/ps/" + str(event.button_index) + ".png")
		elif event is InputEventKey:
			keyboardButton = load("res://assets/ui/buttons/kbm/" + event.as_text_physical_keycode() + "_Key_Dark.png")
	
	self.texture = keyboardButton

func _input(event):
	if event is InputEventKey || event is InputEventMouseMotion:
		self.texture = keyboardButton
	
	if event is InputEventJoypadButton:
		self.texture = controllerButton
