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
			resolved.calculated = handleDamage(actor, target, command, resistMultiplier, effectValues[0], absorb)
		Enums.COMMAND_EFFECT_TYPE.HP_HEAL, \
		Enums.COMMAND_EFFECT_TYPE.MP_HEAL, \
		Enums.COMMAND_EFFECT_TYPE.ALL_HEAL:
			resolved.calculated = handleHeal(actor, target, command, effectValues[0])
		Enums.COMMAND_EFFECT_TYPE.HP_DRAIN, \
		Enums.COMMAND_EFFECT_TYPE.MP_DRAIN, \
		Enums.COMMAND_EFFECT_TYPE.ALL_DRAIN:
			resolved.calculated = handleDrain(actor, target, command, resistMultiplier, effectValues[0])
		Enums.COMMAND_EFFECT_TYPE.GRAVITY:
			resolved.calculated = handleGravity(target, effectValues[0], absorb)
	
	if prevHP != 0 && target.stats.HP == 0:
		resolved.didTargetDie = true
	
	return resolved

func handleDamage(actor: Object, target: Object, command: Dictionary, resistMultiplier: float, effectValues: Array, absorb: bool):
	var calculatedValues = []
	# TODO: Miss and crit logic
	
	var miss = false
	
	var actorStrength = actor.stats.ATK if command.element == Enums.ELEMENT.PHYSICAL else actor.stats.MATK
	var targetDefense = target.stats.DEF if command.element == Enums.ELEMENT.PHYSICAL else target.stats.MDEF
	
	var calculated = damageFormula(actor.stats.level, actorStrength, targetDefense, effectValues[0], resistMultiplier)
	
	match command.effectType:
		Enums.COMMAND_EFFECT_TYPE.HP_DAMAGE:
			target.stats.reduceHP(calculated)
			calculatedValues.append(createCalculatedValue(calculated, Enums.BATTLE_CALCULATED_VALUE.HP))
		Enums.COMMAND_EFFECT_TYPE.MP_DAMAGE:
			target.stats.reduceMP(calculated)
			calculatedValues.append(createCalculatedValue(calculated, Enums.BATTLE_CALCULATED_VALUE.MP))
		Enums.COMMAND_EFFECT_TYPE.ALL_DAMAGE:
			target.stats.reduceHP(calculated)
			calculatedValues.append(createCalculatedValue(calculated, Enums.BATTLE_CALCULATED_VALUE.HP))
			
			var calc2 = damageFormula(actor.stats.level, actorStrength, targetDefense, effectValues[1], resistMultiplier)
			target.stats.reduceMP(calc2)
			calculatedValues.append(createCalculatedValue(calculated, Enums.BATTLE_CALCULATED_VALUE.MP))
	
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
		calculated = healFormula(actor.stats.level, actorStrength, effectValues[0])
	
	calculatedValues.append(calculated)
	match command.effectType:
		Enums.COMMAND_EFFECT_TYPE.HP_HEAL:
			if !miss:
				target.stats.increaseHP(calculated)
			calculatedValues.append(createCalculatedValue(calculated, Enums.BATTLE_CALCULATED_VALUE.HP))
		Enums.COMMAND_EFFECT_TYPE.MP_HEAL:
			target.stats.increaseMP(calculated)
			calculatedValues.append(createCalculatedValue(calculated, Enums.BATTLE_CALCULATED_VALUE.MP))
		Enums.COMMAND_EFFECT_TYPE.ALL_HEAL:
			if !miss:
				target.stats.increaseHP(calculated)
			calculatedValues.append(createCalculatedValue(calculated, Enums.BATTLE_CALCULATED_VALUE.HP))
			
			if !miss:
				var calc2 = healFormula(actor.stats.level, actorStrength, effectValues[1])
				target.stats.reduceMP(calc2)
				calculatedValues.append(createCalculatedValue(calculated, Enums.BATTLE_CALCULATED_VALUE.MP))
	
	return calculatedValues

# Drain-type attacks absorbs a portion of the attack damage as HP/MP.
func handleDrain(actor: Object, target: Object, command: Dictionary, resistMultiplier: float, effectValues: Array):
	var calculatedValues = []
	#TODO: miss, crit
	
	var miss = false
	var actorStrength = actor.stats.ATK if command.element == Enums.ELEMENT.PHYSICAL else actor.stats.MATK
	var targetDefense = target.stats.DEF if command.element == Enums.ELEMENT.PHYSICAL else target.stats.MDEF
	
	var calculated = damageFormula(actor.stats.level, actorStrength, targetDefense, effectValues[0], resistMultiplier)
	var drain = floor(calculated * effectValues[1])
	match command.effectType:
		Enums.COMMAND_EFFECT_TYPE.HP_DRAIN:
			target.stats.reduceHP(calculated)
			actor.stats.increaseHP(drain)
			
			calculatedValues.append(createCalculatedValue(calculated, Enums.BATTLE_CALCULATED_VALUE.HP))
			calculatedValues.append(createCalculatedValue(drain, Enums.BATTLE_CALCULATED_VALUE.HP_DRAIN))
		Enums.COMMAND_EFFECT_TYPE.MP_DRAIN:
			target.stats.reduceMP(calculated)
			actor.stats.increaseMP(drain)
			
			calculatedValues.append(createCalculatedValue(calculated, Enums.BATTLE_CALCULATED_VALUE.MP))
			calculatedValues.append(createCalculatedValue(drain, Enums.BATTLE_CALCULATED_VALUE.MP_DRAIN))
		Enums.COMMAND_EFFECT_TYPE.ALL_DRAIN:
			target.stats.reduceHP(calculated)
			actor.stats.increaseHP(drain)
			
			calculatedValues.append(createCalculatedValue(calculated, Enums.BATTLE_CALCULATED_VALUE.HP))
			calculatedValues.append(createCalculatedValue(drain, Enums.BATTLE_CALCULATED_VALUE.HP_DRAIN))
			
			var drain2 = floor(calculated * effectValues[2])
			actor.stats.increaseMP(drain2)
			calculatedValues.append(createCalculatedValue(drain2, Enums.BATTLE_CALCULATED_VALUE.MP_DRAIN))
	
	return calculatedValues

func handleGravity(target: Object, effectValues: Array, absorb: bool):
	var calculatedValues = []
	#TODO: miss, absorb
	
	# Right now gravity type attacks can only deal set percentages.
	var calculated = target.stats.HP / effectValues[0]
	calculatedValues.append(createCalculatedValue(calculated, Enums.BATTLE_CALCULATED_VALUE.HP))
	
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

func createCalculatedValue(value: int, type: Enums.BATTLE_CALCULATED_VALUE):
	return {
		"calculated": value,
		"type": type
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
