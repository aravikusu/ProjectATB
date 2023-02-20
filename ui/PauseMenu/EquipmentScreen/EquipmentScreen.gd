extends MarginContainer

@onready var partyScreen = $"%PartyScreen"
@onready var listScreen = $"%ListScreen"
@onready var equipmentPanels = [$"%AravixEquipment", $"%AylikEquipment", $"%TastyEquipment"]
var panelIdx = 0

@onready var itemList = $"%ItemList"
@onready var listItem = preload("res://ui/PauseMenu/ListItem/ListItem.tscn")
var items = []
var itemIdx = 0

@onready var tabName = $"%List" 

func _ready():
	updateValues()
	
	equipmentPanels[0].activate(0)

func handleInputs():
	if partyScreen.visible:
		if Input.is_action_just_pressed("ui_right"):
			var lastIdx = equipmentPanels[panelIdx].inactivate()
			if panelIdx + 1 >= equipmentPanels.size():
				panelIdx = 0
			else:
				panelIdx += 1
			equipmentPanels[panelIdx].activate(lastIdx)
		if Input.is_action_just_pressed("ui_left"):
			var lastIdx = equipmentPanels[panelIdx].inactivate()
			if panelIdx - 1 < 0:
				panelIdx = equipmentPanels.size() - 1
			else:
				panelIdx -= 1
			equipmentPanels[panelIdx].activate(lastIdx)
		
		if Input.is_action_just_pressed("ui_select"):
			changeMenu()
			prepareList()
		
		if Input.is_action_just_pressed("ui_context"):
			handleEquip(true)
	else:
		if Input.is_action_just_pressed("ui_down"):
			items[itemIdx].inactivate()
			if itemIdx + 1 >= items.size():
				itemIdx = 0
			else:
				itemIdx += 1
		if Input.is_action_just_pressed("ui_up"):
			items[itemIdx].inactivate()
			if itemIdx - 1 < 0:
				itemIdx = items.size() - 1
			else:
				itemIdx -= 1
		
		if Input.is_action_just_pressed("ui_select"):
			if items[itemIdx].canUse:
				handleEquip()
		
		if Input.is_action_just_pressed("ui_cancel"):
			changeMenu()
			emptyList()

func _process(_delta):
	handleInputs()
	
	if !partyScreen.visible:
		items[itemIdx].activate()

func updateValues():
	equipmentPanels[0].setEquipment(Enums.CHARACTER.ARAVIX)
	equipmentPanels[1].setEquipment(Enums.CHARACTER.AYLIK)
	equipmentPanels[2].setEquipment(Enums.CHARACTER.TASTY)

func changeMenu():
	equipmentPanels[panelIdx].toggle()
	partyScreen.visible = !partyScreen.visible
	listScreen.visible = !listScreen.visible

func prepareList():
	var category = equipmentPanels[panelIdx].getCategory()
	
	match category:
		Enums.ITEM_TYPE.WEAPON: tabName.name = "Weapons"
		Enums.ITEM_TYPE.ARMOR: tabName.name = "Armor"
		Enums.ITEM_TYPE.ACCESSORY: tabName.name = "Accessories"
	
	var equipment = Global.get_inventory().filter(func(item): return item.item.category == category)
	
	var currentCharacter = getCurrentCharacter()
	
	var equipped = Global.get_all_equipped_things()
	for item in equipment:
		if Enums.CHARACTER.EVERYONE in item.item.canWear || currentCharacter in item.item.canWear:
			var data = item.item
			var instance = listItem.instantiate()
			itemList.add_child(instance)
			items.append(instance)
			instance.setDetails(data, item.amount)
			var wearing = false
			for thing in equipped:
				# If we have this equipped in this slot already, we ensure that
				# we can unequip it. This can override disabling the item.
				if thing.item.name == data.name:
					instance.setEquipLabel(thing.equippedBy)
					# If each of this item is equipped, we disable it
					if item.amount == thing.equippedBy.size():
						instance.disable()
					
					if currentCharacter in thing.equippedBy:
						wearing = true
			
				instance.setEquipMode(wearing)

func emptyList():
	for item in items:
		item.queue_free()
	items.clear()

func handleEquip(unequip: bool = false):
	var character = getCurrentCharacter()
	var itemSlot = equipmentPanels[panelIdx].idx
	var item = null if unequip else items[itemIdx].item
	Global.equip_new_item(character, itemSlot, item)
	updateValues()
	
	if !unequip:
		changeMenu()
		emptyList()

func getCurrentCharacter():
	match panelIdx:
		0: return Enums.CHARACTER.ARAVIX
		1: return Enums.CHARACTER.AYLIK
		2: return Enums.CHARACTER.TASTY
