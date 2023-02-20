extends MarginContainer

@onready var bg = $BG
@onready var icon = $"%Icon"
@onready var itemName = $"%Name"
@onready var amount = $"%Amount"
@onready var description = $"%Description"
@onready var use = $"%Use"
@onready var button = $"%ButtonIcon"
@onready var disableOverlay = $"%Disable"
@onready var icons = $"%Icons".get_children()
@onready var wearingLabel = $"%WearingLabel"

var item: Dictionary
var amountVal: int
var canUse = false
var wearing = false

func setDetails(i: Dictionary, itemAmount: int):
	item = i
	itemName.text = item.name
	amountVal = itemAmount
	description.text = item.description
	icon.texture = load("res://assets/icons/" + item.icon + ".png")

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

func disable():
	disableOverlay.show()
	canUse = false

func setEquipMode(isWearing: bool):
	if isWearing:
		use.text = "Already wearing"
		button.hide()
	else:
		use.text = "Equip"
		canUse = true

func setEquipLabel(items: Array):
	wearingLabel.show()
	for character in items:
		match character:
			Enums.CHARACTER.ARAVIX: icons[0].show()
			Enums.CHARACTER.AYLIK: icons[1].show()
			Enums.CHARACTER.TASTY: icons[2].show()
			_:
				icons[0].show()
				icons[1].show()
				icons[2].show()
