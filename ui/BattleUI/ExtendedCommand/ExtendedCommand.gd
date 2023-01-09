extends MarginContainer

@onready var bg = $"%BG"
@onready var skillName = $"%SkillName"
@onready var description = $"%SkillDescription"

var skill = null
var partyMember = null
var partner = null
var disabled = true
var hovering

# This process function checks command requirements and enables/disables them.
func _process(_delta):
	if skill != null:
		var actors = [partyMember]
		
		if partner != null:
			actors.append(partner)
		
		var active = checkIfSkillIsUsable(actors)
		
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
		
		if isReady: 
			readyActors.append(actor)
	
	if readyActors.size() == actors.size():
		return true
	else:
		return false

func prepare(partyMem, command, desc):
	partyMember = partyMem
	skill = command
	skillName.text = skill.name
	description.text = desc
	
	if skill.multitech != Enums.MULTITECH_TYPE.NONE:
			partner = PartyHelper.getPartnerForMultitech(partyMember, skill)

func highlight():
	bg.visible = true

func unhighlight():
	bg.visible = false
