extends MarginContainer

@onready var bg = $BG
@onready var icon = $"%Icon"
@onready var itemName = $"%Name"
@onready var amount = $"%Amount"
@onready var description = $"%Description"

func setDetails(displayName: String, itemAmount: int, desc: String, ic: String):
	itemName.text = displayName
	amount.text = "x" + str(itemAmount)
	description.text = desc
	icon.texture = load("res://assets/icons/" + ic + ".png")

func activate():
	itemName.activate()
	bg.show()

func inactivate():
	itemName.altInactivate()
	bg.hide()
