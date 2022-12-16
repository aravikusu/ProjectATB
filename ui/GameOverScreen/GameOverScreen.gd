extends Control

@onready var player = $AnimationPlayer
@onready var button = $Button
func showScreen():
	player.play("fade")

func remove():
	player.play("remove")
	await player.animation_finished
	queue_free()

func _on_button_pressed():
	button.disabled = true
	get_tree().paused = false
	Global.end_game()
	Global.goto_scene("res://scenes/MainMenu/MainMenu.tscn")
	await get_tree().create_timer(0.5).timeout
	remove()
