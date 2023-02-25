extends MarginContainer

@onready var bg = $"%BG"
@onready var skillName = $"%SkillName"
@onready var description = $"%SkillDescription"
@onready var amount = $"%Amount"

var skill = null
var partyMember = null
var partner = null
var disabled = true
var hovering
var itemMode = false

func _ready():
	skillName.label_settings = getFont(1)
	amount.label_settings = getFont(1)
	description.label_settings = getFont(2)

func getFont(which: int):
	var mat = LabelSettings.new()
	mat.font_color = Color("#d5d5d5")
	if which == 1:
		mat.font = load("res://assets/fonts/Roboto-BoldItalic.ttf")
	else:
		mat.font = load("res://assets/fonts/Roboto-Italic.ttf")
		mat.font_size = 13
	return mat

# This process function checks command requirements and enables/disables them.
func _process(_delta):
	if skill != null:
		var actors = [partyMember]
		
		var active = true
		if partner != null:
			actors.append(partner)
		
		if !itemMode:
			active = checkIfSkillIsUsable(actors)
		
		if active:
			skillName.label_settings.font_color = Color("#ffffff")
			description.label_settings.font_color = Color("#ffffff")
			disabled = false
		else:
			skillName.label_settings.font_color = Color("#727272")
			description.label_settings.font_color = Color("#727272")
			disabled = true

# Go through all the checks to see if the player is allowed to use this skill.
func checkIfSkillIsUsable(actors):
	var readyActors = []
	for actor in actors:
		var isReady = true
		
		if actor.ATB != 100:
			isReady = false
		
		if actor.stats.MP < skill.cost:
			isReady = false
		
		if isReady: 
			readyActors.append(actor)
	
	if readyActors.size() == actors.size():
		return true
	else:
		return false

func prepare(partyMem, command, desc, cost: int):
	partyMember = partyMem
	skill = command
	skillName.text = skill.name
	description.text = desc
	
	if itemMode:
			amount.text = "x" + str(cost)
	else:
		amount.text = str(cost) + "MP"
		if skill.multitech != Enums.MULTITECH_TYPE.NONE:
			partner = PartyHelper.getPartnerForMultitech(partyMember, skill)

func highlight():
	bg.visible = true

func unhighlight():
	bg.visible = false
