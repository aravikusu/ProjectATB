extends Node3D

signal triggerBattle(battleData)

func spawn(_location):
	Global.set_party_position(Vector3(1.5, 5, 0))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_dummy_trigger_trigger_battle(battleData):
	var s = emit_signal("triggerBattle", battleData)
	if s != OK:
		Global.printSignalError("TestArea", "_on_spice_trigger_trigger_battle", "triggerBattle")
