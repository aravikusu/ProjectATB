extends Node2D

var currentLocation = {}

var BATTLE_STATE = Enums.BATTLE_STATE.AWAITING_ACTION
var BATTLE_END_STATE = Enums.BATTLE_END_STATE.ONGOING

var actors = []
var actionQueue = []

var commandForTargeting = {}
var currentCommandTotalDamage = 0

var escapeIsPossible : bool

var ceaseEverything = false

@onready var roomAnchor = $CurrentRoomGoesHere
@onready var battleUI = $BattleUI
@onready var targetUI = $TargetUI
@onready var notificationCenter = $NotificationCenter
@onready var effectNumbers = preload("res://ui/EffectNumbers/EffectNumbers.tscn")
@onready var effectText = preload("res://ui/EffectText/EffectText.tscn")
# Called when the node enters the scene tree for the first time.
func _ready():
	# We're loading into the game from the main menu, so we need to fetch
	# the players current location.
	loadRoom(Global.get_last_location(), "location")

# Load the room the player is in and connect all the necessary things.
func loadRoom(roomName: String, location):
	if currentLocation != {}:
		# Currently in a room, unload it
		currentLocation.queue_free()
		currentLocation = {}
	
	currentLocation = load("res://scenes/" + roomName + ".tscn").instantiate()
	roomAnchor.add_child(currentLocation)
	currentLocation.connect("triggerBattle", Callable(self, "startBattle"))
	currentLocation.spawn(location)

func handle_inputs():
	if Global.BATTLE_TARGETING_MODE:
		if Input.is_action_just_pressed("pause"):
			endTargeting()

func _process(_delta):
	if Global.get_game_state() == Enums.GAME_STATE.BATTLE:
		if BATTLE_END_STATE == Enums.BATTLE_END_STATE.ONGOING:
			handle_inputs()
			if BATTLE_STATE == Enums.BATTLE_STATE.AWAITING_ACTION:
				for actor in actors:
					if actor.CHARACTER_BATTLE_STATE != Enums.CHARACTER_BATTLE_STATE.DEAD:
						if actor.ATB < 100:
							actor.setOverworldSprite()
							actor.ATB += actor.stats.SPD * 0.1
							actor.CHARACTER_BATTLE_STATE = Enums.CHARACTER_BATTLE_STATE.CHARGING
						else:
							actor.ATB = 100
							actor.setReadySprite()
							actor.CHARACTER_BATTLE_STATE = Enums.CHARACTER_BATTLE_STATE.READY
							if !actor.playerControlled:
								# If the actor is an enemy, take immediate action
								handleEnemyCommand(actor)
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
	escapeIsPossible = battleData.canRun
	
	battleUI.startBattle()
	if battleData.initMessage != "":
		battleUI.showNotification(battleData.initMessage)
	
	# Put all battle actors in an array...
	actors.append_array(battleData.party)
	actors.append_array(battleData.enemies)
	
	# Connect signals.
	for actor in actors:
		print(actor)
		actor.connect("targetedForAction", Callable(targetUI, "addTarget"))
		actor.connect("consideredTarget", Callable(targetUI, "consideredTarget"))
		actor.connect("noLongerConsideredTarget", Callable(targetUI, "noLongerConsideredTarget"))
	
	# We will now move the party members in position.
	battleData.leader.forceMove(battleData.positions[0])
	Global.toggle_leader_visibility()
	for i in 3:
		battleUI.fillPartyData(i, battleData.party[i])
		battleData.party[i].moveToLocation(battleData.positions[i])

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
	command.actor.CHARACTER_BATTLE_STATE = Enums.CHARACTER_BATTLE_STATE.WAITING_TO_ACT
	
	if command.partner != null:
		command.partner.CHARACTER_BATTLE_STATE = Enums.CHARACTER_BATTLE_STATE.WAITING_TO_ACT
	
	actionQueue.append(command)

# We come here after having selected a command.
func prepareTargeting(slot, command, partner):
	commandForTargeting = {
		"actor": actors[slot - 1],
		"command": command,
		"target": null,
		"partner": partner
	}
	match commandForTargeting.command.target:
		Enums.TARGET_TYPE.ANY, \
		Enums.TARGET_TYPE.LINE, \
		Enums.TARGET_TYPE.SHAPE:
			var commandActors = [commandForTargeting.actor]
			if partner != null:
				commandActors.append(partner)
			
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
			commandForTargeting.target = actors[slot - 1]
			addToActionQueue(commandForTargeting)

# Once targeting is complete, we come here to finally put the command to the action queue.
func confirmTarget(targets: Array):
	commandForTargeting.target = targets
	
	addToActionQueue(commandForTargeting)
	commandForTargeting = {}
	endTargeting()

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
		
		var animation = load("res://assets/animations/" + action.command.name + ".tscn").instantiate()
		add_child(animation)
		animation.connect("hit", Callable(self, "commandHit"))
		animation.connect("completed", Callable(self, "finishCommand"))
		animation.start(action)
	else:
		# Action was interuppted.
		battleUI.showNotification("... %a cancels their attack!", action.actor.displayName)
		BATTLE_STATE = Enums.BATTLE_STATE.AWAITING_ACTION

# Called during animations. Damage calculations, EffectNumbers
func commandHit(action, effectNumberPos, effectNumberDirection):
	
	if action.command.name == "Run":
		# A BEAUTIFUL WAY OF HANDLING THIS AND NOT A HACK I PROMISE
		handleRun()
	else:
		# TODO: Everything?? Damage calculations, status hits, EVERYTHING
		var damage = 1
		
		for target in action.target:
			var prevHP = target.currentHP
			var newHP = target.currentHP - damage
			if newHP < 0:
				target.currentHP = 0
			else:
				target.currentHP = newHP
			
			if newHP == 0 && prevHP > 0:
				target.CHARACTER_BATTLE_STATE = Enums.CHARACTER_BATTLE_STATE.DEAD
				target.ATB = 0
				displayEffectText("dead", effectNumberPos)
				target.playDeadAnimation()
			
			currentCommandTotalDamage += damage
			
			displayEffectNumber(effectNumberPos, damage, effectNumberDirection)

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
	currentCommandTotalDamage = 0

func displayEffectNumber(startPosition: Vector2, value: int, direction: String):
	var numberInstance = effectNumbers.instantiate()
	add_child(numberInstance)
	numberInstance.prepare(startPosition, value, direction)

func displayEffectText(type: String, location: Vector2):
	var textInstance = effectText.instantiate()
	add_child(textInstance)
	match type:
		"dead":
			textInstance.showDead(location)

# Run has to be handled differently...
func handleRun():
	var success = false
	#TODO: Actual handling of this. Discuss these details.
	
	if success:
		# Do whatever is needed for escaping...
		pass
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
		if actor.currentHP == 0: deadGuys.append(dudes)
	
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
			Enums.BATTLE_END_STATE.RAN_AWAY:
				pass

# Battle has ended in the players favor - reset all battle things
# to default and reward the player
func postBattleCleanup():
	# TODO: rewards
	
	battleUI.end()
	await get_tree().create_timer(1.0).timeout
	notificationCenter.addRewardNotification("You got nothing...")
	Global.set_game_state(Enums.GAME_STATE.ROAMING)
	BATTLE_STATE = Enums.BATTLE_STATE.AWAITING_ACTION
	BATTLE_END_STATE = Enums.BATTLE_END_STATE.ONGOING
	commandForTargeting = {}
	actors[0].postBattleClean()
	actors[1].postBattleClean()
	actors[2].postBattleClean()
	actors.clear()
	actionQueue.clear()
	ceaseEverything = false
	Global.toggle_leader_visibility()
