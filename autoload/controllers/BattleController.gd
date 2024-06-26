extends Node

var BATTLE_STATE = Enums.BATTLE_STATE.AWAITING_ACTION
var BATTLE_END_STATE = Enums.BATTLE_END_STATE.ONGOING

var actors = []
var actionQueue = []

var commandForTargeting = {}
var currentCommandHitsSoFar = 0
var currentCommandTotalDamage = 0

var escapeIsPossible : bool
var runChance = 0.0

var camera : Camera3D

var ceaseEverything = false

@onready var battleUI = $BattleUI
@onready var targetUI = $TargetUI
@onready var damageNumbers = preload("res://ui/Numbers/DamageNumbers/DamageNumbers.tscn")
@onready var healNumbers = preload("res://ui/Numbers/HealNumbers/HealNumbers.tscn")
@onready var effectText = preload("res://ui/EffectText/EffectText.tscn")

func handle_inputs():
	if Global.BATTLE_TARGETING_MODE:
		if Input.is_action_just_pressed("ui_cancel"):
			endTargeting()
			var showExtended = commandForTargeting.command.name != "Attack"
			battleUI.reappearRadialMenu(showExtended)
 
func _process(_delta):
	if Global.get_game_state() == Enums.GAME_STATE.BATTLE:
		if BATTLE_END_STATE == Enums.BATTLE_END_STATE.ONGOING:
			handle_inputs()
			if BATTLE_STATE == Enums.BATTLE_STATE.AWAITING_ACTION:
				var currentSlot = 1
				for actor in actors:
					if actor.CHARACTER_BATTLE_STATE != Enums.CHARACTER_BATTLE_STATE.DEAD:
						match actor.CHARACTER_BATTLE_STATE:
							Enums.CHARACTER_BATTLE_STATE.CHARGING:
								actor.setOverworldSprite()
								actor.ATB += actor.stats.SPD * 0.1
								if actor.ATB >=100:
									actor.ATB = 100
									actor.CHARACTER_BATTLE_STATE = Enums.CHARACTER_BATTLE_STATE.READY
							Enums.CHARACTER_BATTLE_STATE.READY:
								actor.ATB = 100
								actor.setReadySprite()
								if actor.playerControlled:
									if !battleUI.radialMenuVisible:
											# Radial menu not visible; no one else is ready.
											# show it for the current actor.
											battleUI.showRadialMenu(currentSlot)
											actor.toggleCurrentBattleActor()
								else:
									# If the actor is an enemy, take immediate action
									handleEnemyCommand(actor)
					currentSlot += 1
				checkActionQueue()
				checkForBattleEnd()
		else:
			endBattle()

func endTargeting():
	targetUI.end()

# Starts the fun stuff.
func startBattle(battleData):
	# First things first - set the GAME_STATE to battle.
	# This disables the player's ability to move and interact with the world.
	Global.set_game_state(Enums.GAME_STATE.BATTLE)
	Global.set_party_member_collision(false)
	escapeIsPossible = battleData.canRun
	runChance = battleData.runChance
	battleUI.startBattle()
	if battleData.initMessage != "":
		battleUI.showNotification(battleData.initMessage)
	
	# Transition to the battle camera...
	camera = battleData.camera
	TransitionCamera.transition(Global.get_player_camera(), camera)
	
	# Put all battle actors in an array...
	actors.append_array(battleData.party)
	actors.append_array(battleData.enemies)
	targetUI.sendActors(actors)
	
	# We will now move the party members in position.
	for i in 3:
		battleUI.fillPartyData(i, battleData.party[i])
		battleData.party[i].forceMove(battleData.positions[i])

# Gets called every frame in the _process() function during battle.
# Checks if there are any actions waiting to be played out.
func checkActionQueue():
	if actionQueue.size() > 0:
		var nextAction = actionQueue.pop_front()
		if canActorActuallyTakeAction(nextAction):
			BATTLE_STATE = Enums.BATTLE_STATE.PLAYING_ACTION
			nextAction.actor.CHARACTER_BATTLE_STATE = Enums.CHARACTER_BATTLE_STATE.WAITING_TO_ACT
			nextAction.actor.ATB = 0
			
			if nextAction.partner != null:
				nextAction.partner.CHARACTER_BATTLE_STATE = Enums.CHARACTER_BATTLE_STATE.WAITING_TO_ACT
				nextAction.partner.ATB = 0
			
			executeCommand(nextAction)
		else:
			# Actor is currently unable to act; reset character states
			if nextAction.actor.CHARACTER_BATTLE_STATE != Enums.CHARACTER_BATTLE_STATE.DEAD:
				nextAction.actor.CHARACTER_BATTLE_STATE = Enums.CHARACTER_BATTLE_STATE.CHARGING
			
			if nextAction.partner != null:
				if nextAction.partner.CHARACTER_BATTLE_STATE != Enums.CHARACTER_BATTLE_STATE.DEAD:
					nextAction.partner.CHARACTER_BATTLE_STATE = Enums.CHARACTER_BATTLE_STATE.READY

func canActorActuallyTakeAction(nextAction: Dictionary):
	# TODO: Check statuses when they exist.
	
	if nextAction.actor.CHARACTER_BATTLE_STATE == Enums.CHARACTER_BATTLE_STATE.DEAD:
		return false
	
	
	
	return true

# Adds the actor as well as the command they want to execute to the queue.
func addToActionQueue(command):
	if command.actor.playerControlled:
		command.actor.toggleCurrentBattleActor()
	
	command.actor.CHARACTER_BATTLE_STATE = Enums.CHARACTER_BATTLE_STATE.WAITING_TO_ACT
	
	if command.partner != null:
		command.partner.CHARACTER_BATTLE_STATE = Enums.CHARACTER_BATTLE_STATE.WAITING_TO_ACT
	
	actionQueue.append(command)

# We come here after having selected a command.
func prepareTargeting(slot, command, partner, isItem: bool):
	commandForTargeting = {
		"actor": actors[slot - 1],
		"command": command,
		"target": null,
		"partner": partner,
		"isItem": isItem
	}
	match commandForTargeting.command.target:
		Enums.TARGET_TYPE.ANY, \
		Enums.TARGET_TYPE.LINE, \
		Enums.TARGET_TYPE.SHAPE:
			var commandActors = [commandForTargeting.actor]
			if partner != null:
				commandActors.append(partner)
			
			await get_tree().create_timer(0.1).timeout
			Global.set_player_targeting(true)
			targetUI.setTargetMode(commandForTargeting.command.target, commandActors, commandForTargeting.command.additionalTargetInfo)
		Enums.TARGET_TYPE.SELF:
			commandForTargeting.target = [actors[slot - 1]]
			addToActionQueue(commandForTargeting)
		Enums.TARGET_TYPE.ALL_ENEMIES:
			var targets = []
			for actor in actors:
				if !actor.playerControlled:
					targets.append(actor)
			commandForTargeting.target = targets
			addToActionQueue(commandForTargeting)
		Enums.TARGET_TYPE.ACTUALLY_EVERYONE:
			commandForTargeting.target = actors
			addToActionQueue(commandForTargeting)
		Enums.TARGET_TYPE.NONE:
			# For very special cases. Put in self for now,
			# handle separately depending on command.
			commandForTargeting.target = [actors[slot - 1]]
			addToActionQueue(commandForTargeting)

# Once targeting is complete, we come here to finally put the command to the action queue.
func confirmTarget(targets: Array):
	commandForTargeting.target = targets
	
	addToActionQueue(commandForTargeting)
	commandForTargeting = {}
	endTargeting()
	battleUI.hideRadialMenu()

func handleEnemyCommand(actor):
	if !actor.CHARACTER_BATTLE_STATE == Enums.CHARACTER_BATTLE_STATE.WAITING_TO_ACT:
		addToActionQueue(EnemyHelper.decideEnemyAction(actor, actors))

func executeCommand(action):
	var theActionGoesOn = true
	match action.command.target:
		Enums.TARGET_TYPE.ANY, \
		Enums.TARGET_TYPE.LINE, \
		Enums.TARGET_TYPE.SELF:
			# These types of targeting all have one primary target.
			# Check if the primary target is dead.
			if action.target[0].CHARACTER_BATTLE_STATE == Enums.CHARACTER_BATTLE_STATE.DEAD:
				# Target is dead. Remove it.
				# TODO: in the future, have a setting so that the player
				# can choose if they want to re-route to another target or cancel instantly.
				action.target.remove_at(0)
				theActionGoesOn = false
		_:
			# These all hit multiple enemies. Even if the main target is dead,
			# if there is more than 1 target we don't cancel.
			var livingTargets = []
			for target in action.target:
				if target.CHARACTER_BATTLE_STATE != Enums.CHARACTER_BATTLE_STATE.DEAD:
					livingTargets.append(target)
			
			if livingTargets.size() == 0:
				theActionGoesOn = false
	
	if theActionGoesOn:
		if action.command.alternativeDisplayText != null:
			battleUI.showNotification(action.command.alternativeDisplayText, action.actor.displayName)
		else:
			battleUI.showNotification(action.command.name, action.actor.displayName)
		
		# TODO: Deduct costs and what not...
		if action.isItem:
			Global.use_inventory_item(action.command.name)
		else:
			action.actor.stats.reduceMP(action.command.cost)
		
		var animation
		if action.command.animOverride != null:
			animation = load("res://assets/animations/overrides/" + action.command.animOverride + ".tscn").instantiate()
		else:
			animation = load("res://assets/animations/" + action.command.name + ".tscn").instantiate()
		add_child(animation)
		animation.connect("hit", Callable(self, "commandHit"))
		animation.connect("completed", Callable(self, "finishCommand"))
		animation.start(action)
	else:
		# Action was interuppted.
		battleUI.showNotification("... %a cancels their attack!", action.actor.displayName)
		BATTLE_STATE = Enums.BATTLE_STATE.AWAITING_ACTION

# Called during animations. Damage calculations, DamageNumbers
func commandHit(action: Dictionary, effectNumberPos: Vector3, effectNumberDirection: String):
	
	if action.command.name == "Run":
		# A BEAUTIFUL WAY OF HANDLING THIS AND NOT A HACK I PROMISE
		handleRun()
	else:
		effectNumberPos.z += 0.1
		# TODO: Status hits
		var damage = 1
		
		for target in action.target:
			var resolvedDamage = BattleHelper.calculateHit(action.actor, action.command, target, currentCommandHitsSoFar)
			
			if resolvedDamage.didTargetDie:
				target.CHARACTER_BATTLE_STATE = Enums.CHARACTER_BATTLE_STATE.DEAD
				target.ATB = 0
				displayEffectText("dead", effectNumberPos)
				target.playDeadAnimation()
			
			currentCommandHitsSoFar += 1
			currentCommandTotalDamage += damage
			
			for calculated in resolvedDamage.calculated:
				if calculated.mode == "damage":
					match calculated.type:
						Enums.BATTLE_CALCULATED_VALUE.HP:
							displayDamageNumber(effectNumberPos, calculated.calculated, effectNumberDirection)
						Enums.BATTLE_CALCULATED_VALUE.MP:
							displayDamageNumber(effectNumberPos, calculated.calculated, effectNumberDirection, true)
				else:
					match calculated.type:
						Enums.BATTLE_CALCULATED_VALUE.HP:
							displayHealNumber(effectNumberPos, calculated.calculated, "hp")
						Enums.BATTLE_CALCULATED_VALUE.MP:
							displayHealNumber(effectNumberPos, calculated.calculated, "mp")

# We come here after animations have finished playing.
# Everything post-attack is handled here; states, ui things, etc.
func finishCommand(action):
	if action.command.hits > 1:
		battleUI.showMultihit(action.command.hits, currentCommandTotalDamage)
	
	if action.actor.CHARACTER_BATTLE_STATE != Enums.CHARACTER_BATTLE_STATE.DEAD:
		action.actor.CHARACTER_BATTLE_STATE = Enums.CHARACTER_BATTLE_STATE.CHARGING
	if action.partner != null:
		if action.partner.CHARACTER_BATTLE_STATE != Enums.CHARACTER_BATTLE_STATE.DEAD:
			action.partner.CHARACTER_BATTLE_STATE = Enums.CHARACTER_BATTLE_STATE.CHARGING
	
	BATTLE_STATE = Enums.BATTLE_STATE.AWAITING_ACTION
	currentCommandHitsSoFar = 0
	currentCommandTotalDamage = 0

func displayDamageNumber(startPosition: Vector3, value: int, direction: String, mp = false):
	var numberInstance = damageNumbers.instantiate()
	add_child(numberInstance)
	if mp:
		numberInstance.setMPMode()
	numberInstance.prepare(startPosition, value, direction)

func displayHealNumber(startPosition: Vector3, value: int, mode):
	var numberInstance = healNumbers.instantiate()
	add_child(numberInstance)
	numberInstance.prepare(startPosition, value, mode)

func displayEffectText(type: String, location: Vector3):
	var textInstance = effectText.instantiate()
	add_child(textInstance)
	match type:
		"dead":
			textInstance.showDead(location)

# Run has to be handled differently...
func handleRun():
	var success = false
	
	# Do more thorough checking on this. Should speed be taken into account as well?
	
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	if rng.randf_range(0.0, 1.0) < runChance:
		success = true
	
	if success:
		# Do whatever is needed for escaping...
		battleUI.showNotification("... and managed to get away!")
		BATTLE_END_STATE = Enums.BATTLE_END_STATE.RAN_AWAY
	else:
		if escapeIsPossible:
			battleUI.showNotification("... but didn't manage to get away!")
		else:
			battleUI.showNotification("... but running is futile!")

# Runs at the end of every frame while the battle is ongoing.
func checkForBattleEnd():
	if BATTLE_END_STATE == Enums.BATTLE_END_STATE.RAN_AWAY:
		# No point in checking dead dudes...
		pass
	else:
		var goodGuys = []
		var badGuys = []
		for actor in actors:
			if actor.playerControlled:
				goodGuys.append(actor)
			else:
				badGuys.append(actor)
		
		var itsDecided = false
		var youAreAllFucked = areYouDeadYet(goodGuys)
		var theyDidIt = areYouDeadYet(badGuys)
		
		if youAreAllFucked && theyDidIt:
			# ...you still lose, though.
			BATTLE_END_STATE = Enums.BATTLE_END_STATE.STALEMATE
			itsDecided = true
		
		if youAreAllFucked && !itsDecided:
			BATTLE_END_STATE = Enums.BATTLE_END_STATE.PLAYER_LOSS
			itsDecided = true
		
		if theyDidIt && !itsDecided:
			BATTLE_END_STATE = Enums.BATTLE_END_STATE.PLAYER_WIN

func areYouDeadYet(dudes: Array):
	var deadGuys = []
	for actor in dudes:
		if actor.stats.HP == 0: deadGuys.append(dudes)
	
	if deadGuys.size() == dudes.size():
		return true
	else:
		return false

func endBattle():
	if !ceaseEverything:
		ceaseEverything = true
		
		await get_tree().create_timer(2).timeout
		if BATTLE_END_STATE == Enums.BATTLE_END_STATE.STALEMATE:
			battleUI.showNotification("... well, this is awkward.")
			await get_tree().create_timer(2).timeout
			battleUI.showNotification("You still lose though.")
			await get_tree().create_timer(2).timeout
			battleUI.showNotification("Sorry.")
			await get_tree().create_timer(1).timeout
			BATTLE_END_STATE = Enums.BATTLE_END_STATE.PLAYER_LOSS
		
		match BATTLE_END_STATE:
			Enums.BATTLE_END_STATE.PLAYER_WIN:
				postBattleCleanup()
			Enums.BATTLE_END_STATE.PLAYER_LOSS:
				Global.show_game_over()
				battleUI.clearPartyUI()
			Enums.BATTLE_END_STATE.RAN_AWAY:
				postBattleCleanup(true)

# Battle has ended in the players favor - reset all battle things
# to default and reward the player
func postBattleCleanup(ranAway = false):
	# TODO: rewards
	
	battleUI.end()
	await get_tree().create_timer(1.0).timeout
	if !ranAway:
		NotificationController.addUpdateNotification("You got nothing...")
	Global.set_game_state(Enums.GAME_STATE.ROAMING)
	BATTLE_STATE = Enums.BATTLE_STATE.AWAITING_ACTION
	BATTLE_END_STATE = Enums.BATTLE_END_STATE.ONGOING
	commandForTargeting = {}
	actors[0].postBattleClean()
	actors[1].postBattleClean()
	actors[2].postBattleClean()
	actors.clear()
	actionQueue.clear()
	TransitionCamera.transition(camera, Global.get_player_camera())
	ceaseEverything = false
