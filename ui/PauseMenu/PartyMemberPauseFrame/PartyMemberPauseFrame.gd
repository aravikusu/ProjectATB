extends Control

@export var characterType: Enums.CHARACTER = Enums.CHARACTER.NONE

var connectedPartyMember = {}

@onready var icon = $"%Icon"
@onready var displayName = $"%Name"
@onready var hp = $"%HP"
@onready var mp = $"%MP"

@onready var hpLabel = $"%HPLabel"
@onready var mpLabel = $"%MPLabel"
@onready var lvlLabel = $"%LevelNum"
@onready var lvlText = $"%Level"

@onready var particles = $"GPUParticles2D"

func _ready():
	connectedPartyMember = Global.get_party_member_by_type(characterType)
	
	if connectedPartyMember.active:
		match connectedPartyMember.characterType:
			Enums.CHARACTER.ARAVIX:
				icon.modulate = Color("#446abd")
			Enums.CHARACTER.AYLIK:
				icon.modulate = Color("#218251")
			Enums.CHARACTER.TASTY:
				icon.modulate = Color("#ba7ca7")
			Enums.CHARACTER.MONSTER:
				icon.modulate = Color("#774b2c")
		update()
		
		if characterType == Enums.CHARACTER.MONSTER:
			lvlLabel.hide()
			lvlText.hide()
	else:
		hide()

func update():
	displayName.text = connectedPartyMember.displayName
	hp.max_value = connectedPartyMember.stats.maxHP
	mp.max_value = connectedPartyMember.stats.maxMP
	hp.value = connectedPartyMember.stats.HP
	mp.value = connectedPartyMember.stats.MP
	hpLabel.text = str(connectedPartyMember.stats.HP) + "/" + str(connectedPartyMember.stats.maxHP)
	mpLabel.text = str(connectedPartyMember.stats.MP) + "/" + str(connectedPartyMember.stats.maxMP)
	lvlLabel.text = str(connectedPartyMember.stats.Level)

func activateParticles():
	particles.emitting = true

func activate():
	displayName.activate()

func inactivate():
	displayName.inactivate()
