extends MarginContainer

@onready var bg = $BG
@onready var icon = $"%Icon"
@onready var itemName = $"%Name"
@onready var amount = $"%Amount"
@onready var description = $"%Description"
@onready var use = $"%Use"
@onready var button = $"%ButtonIcon"

var mode = "item"

var iName: String
var amountVal: int
var canUse = false

func setDetails(displayName: String, itemAmount: int, desc: String, ic: String):
	iName = displayName
	itemName.text = displayName
	amountVal = itemAmount
	description.text = desc
	icon.texture = load("res://assets/icons/" + ic + ".png")

func _process(_delta):
	amount.text = "x" + str(amountVal)

func activate():
	itemName.activate()
	bg.show()
	if canUse:
		use.show()
		button.show()

func inactivate():
	itemName.altInactivate()
	bg.hide()
	use.hide()
	button.hide()
