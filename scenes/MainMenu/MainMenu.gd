extends Control


@onready var button = $Button
func _on_button_pressed():
	button.disabled = true
	Global.init_savegame()
	Global.partyFormationShuffler()
	var location = Global.get_last_location()
	Global.goto_scene("res://scenes/" + location + "/" + location + ".tscn")
