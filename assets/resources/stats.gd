class_name Stats
extends Resource

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

func reduceMP(cost: int):
	MP = MP - cost

	if MP < 0:
		MP = 0
