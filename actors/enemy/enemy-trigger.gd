extends Area2D
# A shared script for Areas. When the player walks into it, battle starts.

signal triggerBattle(battleData)

# Used to get the enemies tied to this trigger.
@export var enemyGroup := ""
@export var partyPositions := [Vector2()]
@export var battleInitMessage = ""
@export var canRun = true

# Called when the node enters the scene tree for the first time.
func _ready():
	connect("body_entered", Callable(self, "entered"))

func entered(body):
	if body == Global.get_player_character():
		set_deferred("monitoring", false)
		var s = emit_signal("triggerBattle", {
			"leader": Global.get_player_character(),
			"party": Global.get_active_party(),
			"enemies": get_tree().get_nodes_in_group(enemyGroup),
			"positions": partyPositions,
			"initMessage": battleInitMessage,
			"canRun": canRun
		})
		
		if s != OK:
			Global.printSignalError("BattleUI", "entered", "triggerBattle")
