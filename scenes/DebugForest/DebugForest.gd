extends Node3D

func _ready():
	Global.set_party_position(Vector3(1.5, 5, 0))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_dummy_trigger_trigger_battle(battleData):
	BattleController.startBattle(battleData)
