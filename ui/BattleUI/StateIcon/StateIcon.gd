extends TextureRect

@onready var waitIcon = preload("res://assets/ui/state-waiting.png")
@onready var actionIcon = preload("res://assets/ui/state-action.png")
@onready var readyIcon = preload("res://assets/ui/state-ready.png")
@onready var deadIcon = preload("res://assets/ui/state-dead.png")

var currentState

# Called every frame. 'delta' is the elapsed time since the previous frame.
func setIcon(state):
	currentState = state
	match state:
		Enums.CHARACTER_BATTLE_STATE.CHARGING:
			texture = waitIcon
		Enums.CHARACTER_BATTLE_STATE.WAITING_TO_ACT:
			texture = actionIcon
		Enums.CHARACTER_BATTLE_STATE.READY:
			texture = readyIcon
		Enums.CHARACTER_BATTLE_STATE.DEAD:
			texture = deadIcon
