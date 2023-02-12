extends Control

@onready var categoryButtons = $"%CategoryButtons".get_children()
@onready var hintLabel = $"%HintLabel"
@onready var actualMenu = $"%ActualMenu"

@onready var overviewMenu = preload("res://ui/PauseMenu/OverviewScreen/OverviewScreen.tscn")

var activeMenu : MarginContainer = null

var categoryIdx = 4 # Default to Overview

var mode = 0

func handleInputs():
	if Input.is_action_just_pressed("pause"):
		unpause()
	
	match mode:
		0:
			categoryInputs()

func categoryInputs():
	if Input.is_action_just_pressed("ui_right"):
		categoryButtons[categoryIdx].inactivate()
		if categoryIdx + 1 >= categoryButtons.size():
			categoryIdx = 0
		else:
			categoryIdx += 1
	if Input.is_action_just_pressed("ui_left"):
		categoryButtons[categoryIdx].inactivate()
		if categoryIdx - 1 < 0:
			categoryIdx = categoryButtons.size() - 1
		else:
			categoryIdx -= 1

func _ready():
	setActiveMenu()

func _process(_delta):
	handleInputs()
	
	for i in categoryButtons.size():
		categoryButtons[i - 1].inactivate()
	
	categoryButtons[categoryIdx].activate()
	showCategoryHint()

func showCategoryHint():
	var text = "> "
	match categoryIdx:
		0:
			text += "Change the order of your party."
		1:
			text += "Manage the character-specific Awakening skills."
		2:
			text += "Look at (or use) a character's skills."
		3:
			text += "Manage your equipment."
		4:
			text += "Get an overview of your adventure."
		5:
			text += "Manage your items."
		6:
			text += "Strengthen your party by learning new skills."
		7:
			text += "Read up on anything and everything."
		8:
			text += "Configure your settings."
	
	hintLabel.text = text

func setActiveMenu():
	var menu: MarginContainer
	
	match categoryIdx:
		4: 
			menu = overviewMenu.instantiate()
	
	actualMenu.add_child(menu)
	activeMenu = menu

@onready var player = $AnimationPlayer
func showPause():
	visible = true

func unpause():
	get_tree().paused = false
	queue_free()
