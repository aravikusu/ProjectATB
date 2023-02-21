extends MarginContainer

@onready var listItem = preload("res://ui/PauseMenu/ListItem/ListItem.tscn")

@onready var tabs = $"%Tabs"
@onready var aravixList = $"%AravixList"
@onready var aylikList = $"%AylikList"
@onready var tastyList = $"%TastyList"
@onready var monsterList = $"%MonsterList"

@onready var sidething = $"%Sidething"

@onready var overlay = $"%Overlay"
@onready var useMenu = $"%UseMenu"

var aravix = []
var aylik = []
var tasty = []
var monster = []

var activeMenu: Array
var menuIdx = 0
var itemIdx = 0

var useMode = false

# Called when the node enters the scene tree for the first time.
func _ready():
	useMenu.skillMode = true
	var party = Global.get_all_party_members()
	var allTabs = tabs.get_children()
	
	var partyIdx = 0
	var alreadyRemoved = 0
	for member in party:
		if member.active:
			allTabs[partyIdx - alreadyRemoved].name = member.displayName
			for skill in member.commands:
				var instance = listItem.instantiate()
				
				match member.characterType:
					Enums.CHARACTER.ARAVIX:
						aravixList.add_child(instance)
						aravix.append(instance)
					Enums.CHARACTER.AYLIK:
						aylikList.add_child(instance)
						aylik.append(instance)
					Enums.CHARACTER.TASTY:
						tastyList.add_child(instance)
						tasty.append(instance)
					Enums.CHARACTER.MONSTER:
						monsterList.add_child(instance)
						monster.append(instance)
				
				if skill.useInMenu:
					instance.canUse = true
				else:
					instance.disable()
					instance.setSkillLabel("Can only use in combat.")
				
				if member.stats.MP < skill.cost:
					instance.disable()
					instance.setSkillLabel("Not enough MP")
				
				instance.setDetails(skill, skill.cost, "MP")
		else:
			allTabs[partyIdx - alreadyRemoved].queue_free()
			alreadyRemoved += 1
		partyIdx += 1
	
	aravixList.get_child(0).queue_free()
	setActiveMenu()

func handleInputs():
	if !useMode:
		if Input.is_action_just_pressed("ui_select"):
			if activeMenu.size() > 0:
				if activeMenu[itemIdx].canUse:
					handleUse()
		
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
			if activeMenu.size() > 0:
				activeMenu[itemIdx].inactivate()
				if itemIdx + 1 >= activeMenu.size():
					itemIdx = 0
				else:
					itemIdx += 1
				updateSideStuff()
		if Input.is_action_just_pressed("ui_up"):
			if activeMenu.size() > 0:
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
		0: activeMenu = aravix
		1: activeMenu = aylik
		2: activeMenu = tasty
		3: activeMenu = monster
	updateSideStuff()

func updateSideStuff():
	if activeMenu.size() > 0:
		sidething.setStuff(activeMenu[itemIdx].icon.texture)
	else:
		sidething.setStuff(null)

func updateActiveItem():
	var character = getCharacter()
	if character.stats.MP < activeMenu[itemIdx].amountVal:
		activeMenu[itemIdx].disable()
		activeMenu[itemIdx].setSkillLabel("Not enough MP.")

func handleUse():
	await get_tree().create_timer(0.1).timeout
	overlay.show()
	useMenu.show()
	
	var character = getCharacter()
		
	useMenu.setItem(activeMenu[itemIdx], character)
	useMode = true

func hideUse():
	overlay.hide()
	useMenu.hide()
	useMode = false

func _on_use_menu_no_more_items():
	hideUse()
	updateActiveItem()

func getCharacter():
	match menuIdx:
		0: return Global.get_party_member_by_type(Enums.CHARACTER.ARAVIX)
		1: return Global.get_party_member_by_type(Enums.CHARACTER.AYLIK)
		2: return Global.get_party_member_by_type(Enums.CHARACTER.TASTY)
		3: return Global.get_party_member_by_type(Enums.CHARACTER.MONSTER)
