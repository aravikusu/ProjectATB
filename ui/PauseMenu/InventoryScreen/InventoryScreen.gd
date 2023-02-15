extends MarginContainer

@onready var listItem = preload("res://ui/PauseMenu/ListItem/ListItem.tscn")

@onready var tabs = $"%Tabs"
@onready var usableList = $"%UsablesList"
@onready var weaponsList = $"%WeaponsList"
@onready var armorList = $"%ArmorList"
@onready var accessoriesList = $"%AcessoriesList"
@onready var materialsList = $"%MaterialsList"
@onready var keyItemsList = $"%KeyItemsList"

@onready var bigIcon = $"%BigIcon"

var usables = []
var weapons = []
var armor = []
var accessories = []
var materials = []
var keyItems = []

var activeMenu: Array
var menuIdx = 0
var itemIdx = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	var items = Global.get_inventory()
	
	for item in items:
		var data = item.item
		var instance = listItem.instantiate()
		
		match data.category:
			Enums.ITEM_TYPE.USABLE:
				usableList.add_child(instance)
				usables.append(instance)
			Enums.ITEM_TYPE.MATERIAL:
				materialsList.add_child(instance)
				materials.append(instance)
			Enums.ITEM_TYPE.ARMOR:
				armorList.add_child(instance)
				armor.append(instance)
			Enums.ITEM_TYPE.ACCESSORY:
				accessoriesList.add_child(instance)
				accessories.append(instance)
			Enums.ITEM_TYPE.WEAPON:
				materialsList.add_child(instance)
				materials.append(instance)
			Enums.ITEM_TYPE.KEY_ITEM:
				materialsList.add_child(instance)
				materials.append(instance)
		
		instance.setDetails(data.name, item.amount, data.description, data.icon)
	
	setActiveMenu()

func handleInputs():
	if Input.is_action_just_pressed("ui_right"):
		if menuIdx + 1 >= 6:
			menuIdx = 0
		else:
			menuIdx += 1
		itemIdx = 0
		setActiveMenu()
	if Input.is_action_just_pressed("ui_left"):
		if menuIdx - 1 < 0:
			menuIdx = 5
		else:
			menuIdx -= 1
		itemIdx = 0
		setActiveMenu()
	
	if Input.is_action_just_pressed("ui_down"):
		activeMenu[itemIdx].inactivate()
		if itemIdx + 1 >= activeMenu.size():
			itemIdx = 0
		else:
			itemIdx += 1
		updateSideStuff()
	if Input.is_action_just_pressed("ui_up"):
		activeMenu[itemIdx].inactivate()
		if itemIdx - 1 < 0:
			itemIdx = activeMenu.size() - 1
		else:
			itemIdx -= 1
		updateSideStuff()

func _process(_delta):
	if activeMenu.size() > 0:
		activeMenu[itemIdx].activate()
	handleInputs()

func setActiveMenu():
	tabs.current_tab = menuIdx
	match menuIdx:
		0: activeMenu = usables
		1: activeMenu = weapons
		2: activeMenu = armor
		3: activeMenu = accessories
		4: activeMenu = materials
		5: activeMenu = keyItems
	updateSideStuff()

func updateSideStuff():
	if activeMenu.size() > 0:
		bigIcon.texture = activeMenu[itemIdx].icon.texture
	else:
		bigIcon.texture = null
