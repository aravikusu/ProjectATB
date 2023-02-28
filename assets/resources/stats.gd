class_name Stats
extends Resource

### If it's a player character, specify it here.
@export var Player: Enums.CHARACTER = Enums.CHARACTER.NONE

### If it's a monster or enemy, put it here instead.
@export var OtherCreature: CharacterBody3D

var BaseStats: Stats

@export var Level: int
@export var maxHP: int
@export var HP: int
@export var maxMP: int
@export var MP: int
@export var ATK: int
@export var MATK: int
@export var DEF: int
@export var MDEF: int
@export var SPD: int
@export var LUK: int
@export var Fire: Enums.ELEMENT_RESISTANCE = Enums.ELEMENT_RESISTANCE.NEUTRAL
@export var Water: Enums.ELEMENT_RESISTANCE = Enums.ELEMENT_RESISTANCE.NEUTRAL
@export var Ice: Enums.ELEMENT_RESISTANCE = Enums.ELEMENT_RESISTANCE.NEUTRAL
@export var Lightning: Enums.ELEMENT_RESISTANCE = Enums.ELEMENT_RESISTANCE.NEUTRAL
@export var Wind: Enums.ELEMENT_RESISTANCE = Enums.ELEMENT_RESISTANCE.NEUTRAL
@export var Nature: Enums.ELEMENT_RESISTANCE = Enums.ELEMENT_RESISTANCE.NEUTRAL
@export var Earth: Enums.ELEMENT_RESISTANCE = Enums.ELEMENT_RESISTANCE.NEUTRAL
@export var Light: Enums.ELEMENT_RESISTANCE = Enums.ELEMENT_RESISTANCE.NEUTRAL
@export var Dark: Enums.ELEMENT_RESISTANCE = Enums.ELEMENT_RESISTANCE.NEUTRAL
@export var Anima: Enums.ELEMENT_RESISTANCE = Enums.ELEMENT_RESISTANCE.NEUTRAL

# Polled by a global script all the time. Ensures stats are always up to date with
# equipment and buffs.
func update():
	BaseStats = PartyHelper.getPartyMemberStats(Level, Player)
	var equipment = Global.get_equipment_by_type(Player)
	
	if Player != Enums.CHARACTER.MONSTER:
		for equip in equipment.values():
			if equip != null:
				var stats = equip.stats
				
				maxHP += stats.HP
				maxMP += stats.MP
				ATK += stats.ATK
				MATK += stats.MATK
				DEF += stats.DEF
				MDEF += stats.MDEF
				SPD += stats.SPD
				LUK += stats.LUK

func increaseHP(amount: int):
	HP = HP + amount

	if HP > maxHP:
		HP = maxHP

func reduceHP(amount: int):
	HP = HP - amount

	if HP < 0:
		HP = 0

func increaseMP(amount: int):
	MP = MP + amount

	if MP > maxMP:
		MP = maxMP

func reduceMP(amount: int):
	MP = MP - amount

	if MP < 0:
		MP = 0
