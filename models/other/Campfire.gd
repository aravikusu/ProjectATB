extends Area3D


var inrange = false

@onready var prompt = $InteractPrompt
@onready var campsiteMenu = $"%CampsiteMenu"
@onready var campsiteCamera = $CampsiteCamera
# Called when the node enters the scene tree for the first time.
func _ready():
	campsiteMenu.visible = false

func handleInputs():
	if Global.get_game_state() == Enums.GAME_STATE.CAMPSITE:
		pass
	elif Global.get_game_state() == Enums.GAME_STATE.ROAMING:
		if inrange:
			if Input.is_action_just_pressed("ui_select"):
				openCampsiteMenu()
	

func openCampsiteMenu():
	Global.set_game_state(Enums.GAME_STATE.CAMPSITE)
	Global.set_party_member_collision(false)
	campsiteMenu.activate()
	campsiteMenu.visible = true
	inrange = false
	
	#TODO: Camera transition, move party members
	TransitionCamera.transition(Global.get_player_camera(), campsiteCamera, 1.5)
	
	var party = Global.get_active_party()
	var campsitePos = position
	party[0].forceMove(Vector3(campsitePos.x, campsitePos.y, campsitePos.z - 1), 5)
	party[1].forceMove(Vector3(campsitePos.x + 1, party[1].global_position.y, campsitePos.z - 0.3), 5)
	party[2].forceMove(Vector3(campsitePos.x - 1, party[2].global_position.y, campsitePos.z - 0.3), 5)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	handleInputs()
	
	if inrange:
		prompt.visible = true
	else:
		prompt.visible = false

# When the player gets close enough, show an interact prompt
func _on_body_entered(body):
	if body == Global.get_player_character():
		inrange = true

# Hide the interact prompt.
func _on_body_exited(body):
	if body == Global.get_player_character():
		inrange = false
