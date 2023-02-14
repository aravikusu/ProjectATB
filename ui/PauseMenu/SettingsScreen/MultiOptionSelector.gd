extends HBoxContainer

signal sendValue(value: int)

@export var defaultIdx = 0
@export var texts: Array[String]

var isActive = false

@onready var options = get_children()
var optionsIdx = 0
var amount = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	for i in texts.size():
		options[i].show()
		options[i].inactivate()
		options[i].text = texts[i]
		amount += 1

func handleInputs():
	if isActive:
		if Input.is_action_just_pressed("ui_right"):
			options[optionsIdx].inactivate()
			if optionsIdx + 1 >= amount:
				optionsIdx = 0
			else:
				optionsIdx += 1
			send()
		if Input.is_action_just_pressed("ui_left"):
			options[optionsIdx].inactivate()
			if optionsIdx - 1 < 0:
				optionsIdx = amount - 1
			else:
				optionsIdx -= 1
			send()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	handleInputs()
	options[optionsIdx].activate()

func send():
	emit_signal("sendValue", self, optionsIdx)

func forceSet(newIdx: int):
	options[optionsIdx].inactivate()
	optionsIdx = newIdx
