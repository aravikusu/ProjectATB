extends Control

var connectedPartyMember: Object
var actorWasDeadLastFrame = false

@onready var bg = $"%BG"
@onready var icon = $"%Icon"
@onready var hp = $"%HP"
@onready var mp = $"%MP"
@onready var atb = $"%ATB"

@onready var hpLabel = $"%HPLabel"
@onready var mpLabel = $"%MPLabel"
@onready var atbLabel = $"%ATBLabel"

@onready var stateIcon = $"%StateIcon"

func setup(partymember: Object):
	connectedPartyMember = partymember
	
	hp.max_value = connectedPartyMember.maxHP
	mp.max_value = connectedPartyMember.maxMP
	
	match connectedPartyMember.characterType:
		Enums.CHARACTER.ARAVIX:
			bg.modulate = Color("#446abd")
		Enums.CHARACTER.AYLIK:
			bg.modulate = Color("#218251")
		Enums.CHARACTER.TASTY:
			bg.modulate = Color("#ba7ca7")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if connectedPartyMember != null:
		barThings()
		
		var isActorDead = false
		if connectedPartyMember.CHARACTER_BATTLE_STATE == Enums.CHARACTER_BATTLE_STATE.DEAD:
			isActorDead = true
		
		if isActorDead != actorWasDeadLastFrame:
			pass
		
		if stateIcon.currentState != connectedPartyMember.CHARACTER_BATTLE_STATE:
			stateIcon.setIcon(connectedPartyMember.CHARACTER_BATTLE_STATE)

func barThings():
	hp.value = connectedPartyMember.currentHP
	mp.value = connectedPartyMember.currentMP
	atb.value = connectedPartyMember.ATB
	hpLabel.text = str(connectedPartyMember.currentHP) + "/" + str(connectedPartyMember.maxHP)
	mpLabel.text = str(connectedPartyMember.currentMP) + "/" + str(connectedPartyMember.maxMP)
	atbLabel.text = str(floor(connectedPartyMember.ATB)) + "/100"

func clear():
	connectedPartyMember = null
