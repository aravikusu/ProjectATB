class_name EnemyTrigger
extends Area3D
# A shared script for Areas. When the player walks into it, battle starts.

signal triggerBattle(battleData)

# Used to get the enemies tied to this trigger.
@export var enemyGroup := ""
# The positions the party members will walk to.
@export var partyPositions := [Vector3()]
# The message that appears when combat starts.
@export var battleInitMessage = ""
# Decides if the battle can be escaped or not.
@export var canRun = true

@export_range(0.0, 1.0, 0.01) var runChance
# The camera of the battle. If none is found, it will use the default.
@export var battleCamera: Camera3D

# Called when the node enters the scene tree for the first time.
func _ready():
	connect("body_entered", Callable(self, "entered"))

func entered(body):
	if body == Global.get_player_character():
		var cam : Camera3D
		if battleCamera == null:
			cam = Global.get_player_camera()
		else:
			cam = battleCamera
		set_deferred("monitoring", false)
		var s = emit_signal("triggerBattle", {
			"party": Global.get_active_party(),
			"enemies": get_tree().get_nodes_in_group(enemyGroup),
			"positions": partyPositions,
			"initMessage": battleInitMessage,
			"canRun": canRun,
			"runChance": runChance,
			"camera": cam
		})
		
		if s != OK:
			Global.printSignalError("EnemyTrigger", "entered", "triggerBattle")
