extends PanelContainer

@export var character: Enums.CHARACTER = Enums.CHARACTER.NONE

@onready var displayName = $"%Name"
@onready var icon = $"%Icon"
@onready var hpBar = $"%HP"
@onready var mpBar = $"%MP"

@onready var hpLabel = $"%HPLabel"
@onready var mpLabel = $"%MPLabel"

@onready var level = $"%LevelLabel"
@onready var nextLevel = $"%NextLevel"

var elements: Array
var stats: Array

# Called when the node enters the scene tree for the first time.
func _ready():
	var partyMember = Global.get_party_member_by_type(character)
	elements.append_array($"%ElemVals1".get_children())
	elements.append_array($"%ElemVals2".get_children())
	stats.append_array($"%StatVals1".get_children())
	
	match character:
		Enums.CHARACTER.ARAVIX:
			icon.modulate = Color("#446abd")
		Enums.CHARACTER.AYLIK:
			icon.modulate = Color("#218251")
		Enums.CHARACTER.TASTY:
			icon.modulate = Color("#ba7ca7")
		Enums.CHARACTER.MONSTER:
			icon.modulate = Color("#774b2c")
	
	displayName.text = partyMember.displayName
	
	if character == Enums.CHARACTER.MONSTER:
		level.text = " "
		nextLevel.text = " "
	else:
		level.text = "Level " + str(partyMember.stats.Level)
	
	hpBar.max_value = partyMember.stats.maxHP
	hpBar.value = partyMember.stats.HP
	mpBar.max_value = partyMember.stats.maxMP
	mpBar.value = partyMember.stats.MP
	
	hpLabel.text = str(partyMember.stats.HP) + "/" + str(partyMember.stats.maxHP)
	mpLabel.text = str(partyMember.stats.MP) + "/" + str(partyMember.stats.maxMP)
	
	elements[0].text = stringifyResistEnum(partyMember.stats.Fire)
	elements[1].text = stringifyResistEnum(partyMember.stats.Water)
	elements[2].text = stringifyResistEnum(partyMember.stats.Ice)
	elements[3].text = stringifyResistEnum(partyMember.stats.Wind)
	elements[4].text = stringifyResistEnum(partyMember.stats.Lightning)
	elements[5].text = stringifyResistEnum(partyMember.stats.Nature)
	elements[6].text = stringifyResistEnum(partyMember.stats.Earth)
	elements[7].text = stringifyResistEnum(partyMember.stats.Light)
	elements[8].text = stringifyResistEnum(partyMember.stats.Dark)
	
	stats[0].text = str(partyMember.stats.ATK)
	stats[1].text = str(partyMember.stats.MATK)
	stats[2].text = str(partyMember.stats.DEF)
	stats[3].text = str(partyMember.stats.MDEF)
	stats[4].text = str(partyMember.stats.SPD)
	stats[5].text = str(partyMember.stats.LUK)

func stringifyResistEnum(value: Enums.ELEMENT_RESISTANCE):
	match value:
		Enums.ELEMENT_RESISTANCE.NEUTRAL:
			return "Neutral"
		Enums.ELEMENT_RESISTANCE.RESIST:
			return "Resist"
		Enums.ELEMENT_RESISTANCE.NULL:
			return "Null"
		Enums.ELEMENT_RESISTANCE.DRAIN:
			return "Drain"
		Enums.ELEMENT_RESISTANCE.REPEL:
			return "Repel"
		Enums.ELEMENT_RESISTANCE.WEAK:
			return "Weak"
