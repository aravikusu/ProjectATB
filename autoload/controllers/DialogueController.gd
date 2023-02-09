extends Control

var currentNPC: Object

@onready var textbox = $DialogueTextbox
@onready var player = $AnimationPlayer
func startConversation(script: Dictionary, npc: Object):
	currentNPC = npc
	Global.set_game_state(Enums.GAME_STATE.TALKING)
	textbox.begin(script)
	player.play("fade")

func _on_dialogue_textbox_finished():
	Global.set_game_state(Enums.GAME_STATE.ROAMING)
	currentNPC.inrange = true
	currentNPC = Object
	player.play_backwards("fade")
