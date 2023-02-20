extends PanelContainer

var isActive = false

@onready var equipped = [
	$"%WeaponName", $"%ArmorName", 
	$"%Accessory1Name", $"%Accessory2Name", $"%Accessory3Name"
]
var idx = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func handleInputs():
	if isActive:
		if Input.is_action_just_pressed("ui_down"):
			equipped[idx].altInactivate()
			if idx + 1 >= equipped.size():
				idx = 0
			else:
				idx += 1
		if Input.is_action_just_pressed("ui_up"):
			equipped[idx].altInactivate()
			if idx - 1 < 0:
				idx = equipped.size() - 1
			else:
				idx -= 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if isActive:
		equipped[idx].activate()
	handleInputs()

func setEquipment(character: Enums.CHARACTER):
	flush()
	var equipment = Global.get_equipment_by_type(character)
	
	if equipment.weapon != null:
		equipped[0].text = equipment.weapon.name
	if equipment.armor != null:
		equipped[1].text = equipment.armor.name
	if equipment.accessory1 != null:
		equipped[2].text = equipment.accessory1.name
	if equipment.accessory2 != null:
		equipped[3].text = equipment.accessory2.name
	if equipment.accessory3 != null:
		equipped[4].text = equipment.accessory3.name

func swapEquipment():
	var equipmentName = equipped[idx].text

func activate(newIdx: int) -> void:
	idx = newIdx
	isActive = true

func inactivate() -> int:
	equipped[idx].altInactivate()
	isActive = false
	
	return idx

func toggle():
	isActive = !isActive

func getCategory():
	match idx:
		0: return Enums.ITEM_TYPE.WEAPON
		1: return Enums.ITEM_TYPE.ARMOR
		_: return Enums.ITEM_TYPE.ACCESSORY

func flush():
	for item in equipped:
		item.text = ""
