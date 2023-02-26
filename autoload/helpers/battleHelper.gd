extends Node


func calculateHit(actor: Object, command: Dictionary, target: Object, hit: int) -> Dictionary:
	var resolved = {
		"calculated": [],
		"didTargetDie": false
	}
	
	var actualTarget = target
	
	# Make sense of all the resistance related things.
	var targetResist = getActorResistance(actualTarget, command.element)
	var resistMultiplier = 1.0
	var absorb = false

	match targetResist:
		Enums.ELEMENT_RESISTANCE.WEAK: resistMultiplier = 1.5
		Enums.ELEMENT_RESISTANCE.RESIST: resistMultiplier = 0.5
		Enums.ELEMENT_RESISTANCE.NULL: resistMultiplier = 0
		Enums.ELEMENT_RESISTANCE.ABSORB: absorb = true
		Enums.ELEMENT_RESISTANCE.REPEL:
			# If the attack was repelled we have to switch the target to the actor
			actualTarget = actor
	
	var effectValues: Array
	if command.effectValues.size() > 1:
		effectValues = command.effectValues[hit]
	else:
		effectValues = command.effectValues[0]
	
	var prevHP = target.stats.HP
	
	# At this point we have everything we need and can calculate things according to the effect type
	match command.effectType:
		Enums.COMMAND_EFFECT_TYPE.HP_DAMAGE, \
		Enums.COMMAND_EFFECT_TYPE.MP_DAMAGE, \
		Enums.COMMAND_EFFECT_TYPE.ALL_DAMAGE:
			resolved.calculated = handleDamage(actor, target, command, resistMultiplier, effectValues, absorb)
		Enums.COMMAND_EFFECT_TYPE.HP_HEAL, \
		Enums.COMMAND_EFFECT_TYPE.MP_HEAL, \
		Enums.COMMAND_EFFECT_TYPE.ALL_HEAL:
			resolved.calculated = handleHeal(actor, target, command, effectValues)
		Enums.COMMAND_EFFECT_TYPE.HP_DRAIN, \
		Enums.COMMAND_EFFECT_TYPE.MP_DRAIN, \
		Enums.COMMAND_EFFECT_TYPE.ALL_DRAIN:
			resolved.calculated = handleDrain(actor, target, command, resistMultiplier, effectValues)
		Enums.COMMAND_EFFECT_TYPE.GRAVITY:
			resolved.calculated = handleGravity(target, effectValues, absorb)
		Enums.COMMAND_EFFECT_TYPE.STATIC_HP_DAMAGE, \
		Enums.COMMAND_EFFECT_TYPE.STATIC_MP_DAMAGE:
			resolved.calculated = handleStaticDamage(target, command, effectValues, absorb)
		Enums.COMMAND_EFFECT_TYPE.STATIC_HP_HEAL, \
		Enums.COMMAND_EFFECT_TYPE.STATIC_MP_HEAL:
			resolved.calculated = handleStaticHeal(target, command, effectValues, absorb)
	if prevHP != 0 && target.stats.HP == 0:
		resolved.didTargetDie = true
	
	return resolved

func handleDamage(actor: Object, target: Object, command: Dictionary, resistMultiplier: float, effectValues: Array, absorb: bool):
	var calculatedValues = []
	# TODO: Miss and crit logic
	
	var miss = false
	
	var actorStrength = actor.stats.ATK if command.element == Enums.ELEMENT.PHYSICAL else actor.stats.MATK
	var targetDefense = target.stats.DEF if command.element == Enums.ELEMENT.PHYSICAL else target.stats.MDEF
	
	var calculated = damageFormula(actor.stats.Level, actorStrength, targetDefense, effectValues[0], resistMultiplier)
	
	match command.effectType:
		Enums.COMMAND_EFFECT_TYPE.HP_DAMAGE:
			target.stats.reduceHP(calculated)
			calculatedValues.append(createCalculatedValue(calculated, Enums.BATTLE_CALCULATED_VALUE.HP, "damage"))
		Enums.COMMAND_EFFECT_TYPE.MP_DAMAGE:
			target.stats.reduceMP(calculated)
			calculatedValues.append(createCalculatedValue(calculated, Enums.BATTLE_CALCULATED_VALUE.MP, "damage"))
		Enums.COMMAND_EFFECT_TYPE.ALL_DAMAGE:
			target.stats.reduceHP(calculated)
			calculatedValues.append(createCalculatedValue(calculated, Enums.BATTLE_CALCULATED_VALUE.HP, "damage"))
			
			var calc2 = damageFormula(actor.stats.level, actorStrength, targetDefense, effectValues[1], resistMultiplier)
			target.stats.reduceMP(calc2)
			calculatedValues.append(createCalculatedValue(calculated, Enums.BATTLE_CALCULATED_VALUE.MP, "damage"))
	
	return calculatedValues

func handleHeal(actor: Object, target: Object, command: Dictionary, effectValues: Array):
	var calculatedValues = []
	# TODO: Crit
	
	var actorStrength = actor.stats.ATK if command.element == Enums.ELEMENT.PHYSICAL else actor.stats.MATK
	
	# Heals never miss unless the target is dead.
	var miss = false
	if actor.stats.HP < 1:
		miss = true
	
	var calculated
	if miss:
		calculated = "miss"
	else:
		calculated = healFormula(actor.stats.Level, actorStrength, effectValues[0])
	
	match command.effectType:
		Enums.COMMAND_EFFECT_TYPE.HP_HEAL:
			if !miss:
				target.stats.increaseHP(calculated)
			calculatedValues.append(createCalculatedValue(calculated, Enums.BATTLE_CALCULATED_VALUE.HP, "heal"))
		Enums.COMMAND_EFFECT_TYPE.MP_HEAL:
			target.stats.increaseMP(calculated)
			calculatedValues.append(createCalculatedValue(calculated, Enums.BATTLE_CALCULATED_VALUE.MP, "heal"))
		Enums.COMMAND_EFFECT_TYPE.ALL_HEAL:
			if !miss:
				target.stats.increaseHP(calculated)
			calculatedValues.append(createCalculatedValue(calculated, Enums.BATTLE_CALCULATED_VALUE.HP, "heal"))
			
			if !miss:
				var calc2 = healFormula(actor.stats.level, actorStrength, effectValues[1])
				target.stats.increaseMP(calc2)
				calculatedValues.append(createCalculatedValue(calculated, Enums.BATTLE_CALCULATED_VALUE.MP, "heal"))
	
	return calculatedValues

# Drain-type attacks absorbs a portion of the attack damage as HP/MP.
func handleDrain(actor: Object, target: Object, command: Dictionary, resistMultiplier: float, effectValues: Array):
	var calculatedValues = []
	#TODO: miss, crit
	
	var miss = false
	var actorStrength = actor.stats.ATK if command.element == Enums.ELEMENT.PHYSICAL else actor.stats.MATK
	var targetDefense = target.stats.DEF if command.element == Enums.ELEMENT.PHYSICAL else target.stats.MDEF
	
	var calculated = damageFormula(actor.stats.Level, actorStrength, targetDefense, effectValues[0], resistMultiplier)
	var drain = floor(calculated * effectValues[1])
	match command.effectType:
		Enums.COMMAND_EFFECT_TYPE.HP_DRAIN:
			target.stats.reduceHP(calculated)
			actor.stats.increaseHP(drain)
			
			calculatedValues.append(createCalculatedValue(calculated, Enums.BATTLE_CALCULATED_VALUE.HP, "heal"))
			calculatedValues.append(createCalculatedValue(drain, Enums.BATTLE_CALCULATED_VALUE.HP_DRAIN, "heal"))
		Enums.COMMAND_EFFECT_TYPE.MP_DRAIN:
			target.stats.reduceMP(calculated)
			actor.stats.increaseMP(drain)
			
			calculatedValues.append(createCalculatedValue(calculated, Enums.BATTLE_CALCULATED_VALUE.MP, "heal"))
			calculatedValues.append(createCalculatedValue(drain, Enums.BATTLE_CALCULATED_VALUE.MP_DRAIN, "heal"))
		Enums.COMMAND_EFFECT_TYPE.ALL_DRAIN:
			target.stats.reduceHP(calculated)
			actor.stats.increaseHP(drain)
			
			calculatedValues.append(createCalculatedValue(calculated, Enums.BATTLE_CALCULATED_VALUE.HP, "heal"))
			calculatedValues.append(createCalculatedValue(drain, Enums.BATTLE_CALCULATED_VALUE.HP_DRAIN, "heal"))
			
			var drain2 = floor(calculated * effectValues[2])
			actor.stats.increaseMP(drain2)
			calculatedValues.append(createCalculatedValue(drain2, Enums.BATTLE_CALCULATED_VALUE.MP_DRAIN, "heal"))
	
	return calculatedValues

func handleGravity(target: Object, effectValues: Array, absorb: bool):
	var calculatedValues = []
	#TODO: miss, absorb
	
	# Right now gravity type attacks can only deal set percentages.
	var calculated = target.stats.HP / effectValues[0]
	calculatedValues.append(createCalculatedValue(calculated, Enums.BATTLE_CALCULATED_VALUE.HP, "damage"))
	
	return calculatedValues

func handleStaticDamage(target: Object, command: Dictionary, effectValues: Array, absorb: bool):
	var calculatedValues = []
	#TODO: miss, absorb
	
	var calculated = effectValues[0]
	var type
	
	if command.effectType == Enums.COMMAND_EFFECT_TYPE.STATIC_HP_DAMAGE:
		target.stats.reduceHP(calculated)
		type = Enums.BATTLE_CALCULATED_VALUE.HP
	else:
		target.stats.reduceMP(calculated)
		type = Enums.BATTLE_CALCULATED_VALUE.MP
	
	calculatedValues.append(createCalculatedValue(calculated, type, "damage"))
	return calculatedValues

# Static damage/healing will always do the same amount, even if resist/weak.
# Unless absorb/miss, that is
func handleStaticHeal(target: Object, command: Dictionary, effectValues: Array, absorb: bool):
	var calculatedValues = []
	#TODO: miss, absorb
	
	var calculated = effectValues[0]
	var type
	
	if command.effectType == Enums.COMMAND_EFFECT_TYPE.STATIC_HP_HEAL:
		target.stats.increaseHP(calculated)
		type = Enums.BATTLE_CALCULATED_VALUE.HP
	else:
		target.stats.increaseMP(calculated)
		type = Enums.BATTLE_CALCULATED_VALUE.MP
	
	calculatedValues.append(createCalculatedValue(calculated, type, "heal"))
	return calculatedValues

func getActorResistance(actor: Object, resistance: Enums.ELEMENT):
	match resistance:
		Enums.ELEMENT.FIRE:
			return actor.stats.Fire
		Enums.ELEMENT.WATER:
			return actor.stats.Water
		Enums.ELEMENT.ICE:
			return actor.stats.Ice
		Enums.ELEMENT.WIND:
			return actor.stats.Wind
		Enums.ELEMENT.LIGHTNING:
			return actor.stats.Lightning
		Enums.ELEMENT.NATURE:
			return actor.stats.Nature
		Enums.ELEMENT.EARTH:
			return actor.stats.Earth
		Enums.ELEMENT.LIGHT:
			return actor.stats.Light
		Enums.ELEMENT.DARK:
			return actor.stats.Dark
		Enums.ELEMENT.ANIMA:
			return actor.stats.Anima

func createCalculatedValue(value: int, type: Enums.BATTLE_CALCULATED_VALUE, mode: String):
	return {
		"calculated": value,
		"type": type,
		"mode": mode
	}

func damageFormula(actorLevel: int, actorStrength: int, targetDefense: int, power: int, resistMultiplier: float) -> int:
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var damage = ((power * rng.randf_range(1.0, 1.125) - targetDefense) * actorStrength * (actorLevel + actorStrength) / 256) * resistMultiplier
	return floor(damage)

func healFormula(actorLevel: int, actorStrength: int, power: int) -> int:
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var heal = (power * rng.randf_range(1.0, 1.125)) * actorStrength * (actorLevel + actorStrength) / 256
	return floor(heal)
