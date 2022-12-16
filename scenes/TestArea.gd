extends Node2D

signal triggerBattle(battleData)

@onready var animPlayer = $AnimationPlayer

func spawn(_location):
	Global.set_party_position(Vector2(216, 337))

func _on_spice_trigger_body_entered(body):
	if Global.get_player_character() == body:
		animPlayer.play("triggerSpiceLord")

func _on_spice_trigger_trigger_battle(battleData):
	var s = emit_signal("triggerBattle", battleData)
	if s != OK:
		Global.printSignalError("TestArea", "_on_spice_trigger_trigger_battle", "triggerBattle")
