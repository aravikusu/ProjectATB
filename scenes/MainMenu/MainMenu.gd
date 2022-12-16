extends Control


@onready var button = $Button
func _on_button_pressed():
	button.disabled = true
	Global.init_savegame()
	Global.partyFormationShuffler()
	Global.goto_scene("res://scenes/MainScene.tscn")
