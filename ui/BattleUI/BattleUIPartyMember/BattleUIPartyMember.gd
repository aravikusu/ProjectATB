extends MarginContainer
signal showCommandMenu(slot, partyMemberType)
signal actorDied

@export var slot = 1

var connectedPartyMember
var canAct = false
var lastCall = ""
var actorWasDeadLastFrame = false

@onready var HP := $"%HP"
@onready var MP := $"%MP"
@onready var ATB := $"%ATB"
@onready var displayName := $"%Name"
@onready var bg := $"%BG"
@onready var player = $AnimationPlayer
func fillData(partyMember):
	connectedPartyMember = partyMember
	displayName.text = connectedPartyMember.displayName

func _process(_delta):
	if connectedPartyMember != null:
		HP.text = str(connectedPartyMember.currentHP) + "/" + str(connectedPartyMember.maxHP)
		MP.text = str(connectedPartyMember.currentMP) + "/" + str(connectedPartyMember.maxMP)
		ATB.text = str(floor(connectedPartyMember.ATB)) + "/100"
		
		var isActorDead
		if connectedPartyMember.CHARACTER_BATTLE_STATE == Enums.CHARACTER_BATTLE_STATE.DEAD:
			isActorDead = true
		else:
			isActorDead = false
		
		if isActorDead != actorWasDeadLastFrame:
			handleDead(isActorDead)
		
		if !actorWasDeadLastFrame:
			match connectedPartyMember.CHARACTER_BATTLE_STATE:
				Enums.CHARACTER_BATTLE_STATE.CHARGING:
					if lastCall != "full":
						canAct = false
						lastCall = "full"
						bg.color = Color("#00000064")
						mouse_default_cursor_shape = Control.CURSOR_ARROW
				Enums.CHARACTER_BATTLE_STATE.WAITING_TO_ACT:
					if lastCall != "ready":
						canAct = false
						lastCall = "ready"
						bg.color = Color("#37499e64")
						mouse_default_cursor_shape = Control.CURSOR_ARROW
				Enums.CHARACTER_BATTLE_STATE.READY:
					if lastCall != "charge":
						canAct = true
						lastCall = "charge"
						bg.color = Color("#00640064")
						mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		
		if Global.BATTLE_TARGETING_MODE:
			lastCall = ""
			mouse_default_cursor_shape = Control.CURSOR_ARROW
		
		actorWasDeadLastFrame = isActorDead

func handleDead(isDead: bool):
	if isDead:
		canAct = false
		mouse_default_cursor_shape = Control.CURSOR_ARROW
		player.play("dead")
		Global.set_player_targeting(false)
		
		var s = emit_signal("actorDied")
		if s != OK:
			Global.printSignalError("BattleUIPartyMember", "handleDead", "actorDied")
	else:
		canAct = true
		connectedPartyMember.setSprite("overworld")
		player.play_backwards("dead")

func clear():
	connectedPartyMember = null

func _on_gui_input(event):
	if event is InputEventMouseButton && event.pressed && event.button_index == 1:
		if canAct:
			var s = emit_signal("showCommandMenu", slot, connectedPartyMember.characterType)
			if s != OK:
				Global.printSignalError("BattleUIPartyMember", "_on_gui_input", "showCommandMenu")
