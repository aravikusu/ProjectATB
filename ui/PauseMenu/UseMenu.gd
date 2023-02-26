extends Control

signal noMoreItems
signal cancel

var isActive = false

@onready var members = $"%Party".get_children()
@onready var useLabel = $"%UseLabel"

var activeMembers = []
var idx = 0

var activeItem: Object
var connectedCharacter: Object

var skillMode = false

func _ready():
	for member in members:
		if member.connectedPartyMember.active:
			member.inactivate()
			activeMembers.append(member)

func handleInputs():
	if isActive:
		if Input.is_action_just_pressed("ui_right"):
			activeMembers[idx].inactivate()
			if idx + 1 >= activeMembers.size():
				idx = 0
			else:
				idx += 1
		if Input.is_action_just_pressed("ui_left"):
			activeMembers[idx].inactivate()
			if idx - 1 < 0:
				idx = activeMembers.size() - 1
			else:
				idx -= 1
		if Input.is_action_just_pressed("ui_select"):
			if skillMode:
				useSkill()
			else:
				use()
		if Input.is_action_just_pressed("ui_cancel"):
			isActive = false
			emit_signal("cancel")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	activeMembers[idx].activate()
	handleInputs()

func use():
	# TODO: Apply effect
	
	activeItem.amountVal -= 1
	activeMembers[idx].activateParticles()
	Global.use_inventory_item(activeItem.item.name)
	
	if activeItem.amountVal == 0:
		isActive = false
		emit_signal("noMoreItems")

func useSkill():
	activeMembers[idx].activateParticles()
	connectedCharacter.stats.reduceMP(activeItem.item.cost)
	activeMembers[connectedCharacter.characterType].update()
	
	if connectedCharacter.stats.MP < activeItem.item.cost:
		emit_signal("noMoreItems")

func setItem(item: Object, character: Object = Object):
	activeItem = item
	isActive = true
	connectedCharacter = character
	useLabel.text = "Use " + activeItem.item.name + " on..."
