extends Node3D

signal triggerBattle(battleData)

@onready var animPlayer = $AnimationPlayer
# Called when the node enters the scene tree for the first time.
func spawn(_location):
	Global.set_party_position(Vector3(0, 1, 3.914))

func _on_spice_trigger_body_entered(body):
	if Global.get_player_character() == body:
		animPlayer.play("triggerSpiceLord")


func _on_spice_trigger_trigger_battle(battleData):
	var s = emit_signal("triggerBattle", battleData)
	if s != OK:
		Global.printSignalError("TestArea", "_on_spice_trigger_trigger_battle", "triggerBattle")
