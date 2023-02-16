extends Node

const SAVE_DIR = "user://saves/"

var following_scene = ""
var current_scene

var _save_file = {}
var _config_file = {}

var save_path = SAVE_DIR + "save.dat"
var config_path = "user://" + "config.dat"

var gameOverScreen = preload("res://ui/GameOverScreen/GameOverScreen.tscn")
var pauseScreen = preload("res://ui/PauseMenu/PauseMenu.tscn")
var canPause = false
var paused = false

var playerIsDead = false

@onready var player = $AnimationPlayer
@onready var partyMem1 = $PartyTrain/PartyMember1
@onready var partyMem2 = $PartyTrain/PartyMember2
@onready var partyMem3 = $PartyTrain/PartyMember3
@onready var monster = $PartyTrain/Monster

@onready var _GAME_STATE = Enums.GAME_STATE.TITLE_SCREEN

var BATTLE_TARGETING_MODE = false

func handleInputs():
	if _GAME_STATE == Enums.GAME_STATE.ROAMING:
		if Input.is_action_just_pressed("pause"):
			show_pause()
			paused = true
			get_tree().paused = paused

# Called when the node enters the scene tree for the first time.
func _ready():
	get_game_config()
	var root = get_tree().get_root()
	current_scene = root.get_child(root.get_child_count() - 1)
	player.play("SceneFade")

func _process(_delta):
	handleInputs()

# SAVE FILE HANDLERS

func default_save():
	return {
		"location": "DebugForest",
		"player1": {
			"name": "Aravix",
			"type": Enums.CHARACTER.ARAVIX,
			"level": 1,
			"currentHP": 100,
			"currentMP": 100,
			"equipped": {
				"weapon": null,
				"armor": null,
				"acc": null
			},
			"partyPlace": 1
		},
		"player2": {
			"name": "Aylik",
			"type": Enums.CHARACTER.AYLIK,
			"level": 1,
			"currentHP": 100,
			"currentMP": 100,
			"equipped": {
				"weapon": null,
				"armor": null,
				"acc": null
			},
			"partyPlace": 2
		},
		"player3": {
			"name": "Tasty",
			"type": Enums.CHARACTER.TASTY,
			"level": 1,
			"currentHP": 100,
			"currentMP": 100,
			"equipped": {
				"weapon": null,
				"armor": null,
				"acc": null
			},
			"partyPlace": 3
		},
		"monster": {
			"name": "DummyMonster",
			"level": 0,
			"type": Enums.CHARACTER.MONSTER,
			"currentHP": 100,
			"currentMP": 100,
			"partyPlace": 4
		},
		"inventory": [
			{
				"item": Items.DUMMY,
				"amount": 1
			},
			{
				"item": Items.DUMMY2,
				"amount": 2
			}
		],
	}

func default_config():
	return {
		"resolution": 0,
		"aa": 3,
		"vsync": 1,
		"music": 100,
		"sfx": 100,
		"ambiance": 100,
		"voices": 100,
		"atb": 0 
	}

func init_savegame():
	_save_file = default_save()
	save_game()
	set_pause(true)
	set_game_state(Enums.GAME_STATE.ROAMING)

func save_game():
	var dir = DirAccess.open(SAVE_DIR)
	if !dir:
		@warning_ignore("return_value_discarded")
		DirAccess.make_dir_absolute("user://saves/")
	
	var file = FileAccess.open_encrypted_with_pass(save_path, FileAccess.WRITE, "TastyHasAGreatRack")
	if file is Object:
		file.store_var(_save_file)
		print("Game has successfully been saved")
	else:
		print("Uh oh. Game couldn't be saved. Error: " + file)

func load_game():
	if FileAccess.file_exists(save_path):
		var file = FileAccess.open_encrypted_with_pass(save_path, FileAccess.READ, "TastyHasAGreatRack")
		if file is Object:
			_save_file = file.get_var()
			print("Game was successfully loaded")
			return true
		else:
			print("Uh oh. Game couldn't be loaded. Error: " + file)
			return false

func end_game():
	set_game_state(Enums.GAME_STATE.TITLE_SCREEN)
	_save_file = []
	partyMem1.flush()
	partyMem2.flush()
	partyMem3.flush()

func show_game_over():
	set_pause(false)
	var gameOver = gameOverScreen.instantiate()
	$CanvasLayer.add_child(gameOver)
	gameOver.showScreen()
	get_tree().paused = paused

# Used checked the main menu to show if we need to enable/disable the continue button.
func check_if_save_exists():
	if FileAccess.file_exists(save_path):
		return true
	else:
		return false

# RETURNING SAVE FILE VALUES

func get_last_location():
	return _save_file.location

func get_player(number: int):
	return _save_file["player" + str(number)]

# As above, but returns everything at once
func get_party():
	return [_save_file.player1, _save_file.player2, _save_file.player3, _save_file.monster]

func get_party_info_by_slot(slot):
	match slot:
		1: return _save_file.player1
		2: return _save_file.player2
		3: return _save_file.player3
		4: return _save_file.monster

func get_party_member_by_slot(slot):
	match slot:
		1: return partyMem1
		2: return partyMem2
		3: return partyMem3
		4: return monster

# This is not really efficient, but...
func get_party_member_by_type(type):
	var partyMember = null
	
	match type:
		Enums.CHARACTER.ARAVIX:
			partyMember = _save_file.player1
		Enums.CHARACTER.AYLIK:
			partyMember = _save_file.player2
		Enums.CHARACTER.TASTY:
			partyMember = _save_file.player3
		Enums.CHARACTER.MONSTER:
			partyMember = _save_file.monster
	
	return get_party_member_by_slot(partyMember.partyPlace)

# GAME CONFIG FILE HELPERS

func get_config():
	return _config_file

func get_game_config():
	# Check if config exists first..
	if !FileAccess.file_exists(config_path):
		# Either this is the first time the player started the game,
		# or the config was removed. Either way, default it.
		print("Config file not found. Creating.")
		_config_file = default_config()
		save_config()
	else:
		print("Config file found.")
	load_config()
	set_config()

func save_config():
	var file = FileAccess.open_encrypted_with_pass(config_path, FileAccess.WRITE, "TastyHasAGreatRack")
	if file is Object:
		file.store_var(_config_file)
		print("Settings have been saved.")
	else:
		print("Uh oh. Couldn't save settings... Error: " + file)

# This funcion handles all the settings relating to the screen itself.
# Settings like FOV is handled in the Camera3D itself, and SSAO in the Environments
func load_config():
	if FileAccess.file_exists(config_path):
		var file = FileAccess.open_encrypted_with_pass(config_path, FileAccess.READ, "TastyHasAGreatRack")
		if file is Object:
			_config_file = file.get_var()
			print("Settings were successfully loaded.")
			return true
		else:
			print("Uh oh. Settings couldn't be loaded... Error: " + file)
			return false

func set_config():
	#get_tree().set_screen_stretch(SceneTree.STRETCH_MODE_2D, SceneTree.STRETCH_ASPECT_EXPAND, _config_file.resolution)
	
	match _config_file.resolution:
		0: get_tree().root.size = Vector2(1280, 720)
		1: get_tree().root.size = Vector2(1920, 1080)
	
	match _config_file.vsync:
		0: DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
		1: DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	
	match _config_file.aa:
		0: get_viewport().msaa_3d = Viewport.MSAA_DISABLED
		1: get_viewport().msaa_3d = Viewport.MSAA_2X
		2: get_viewport().msaa_3d = Viewport.MSAA_4X
		3: get_viewport().msaa_3d = Viewport.MSAA_8X

func update_config(values: Dictionary):
	_config_file = values
	save_config()
	set_config()

func partyFormationShuffler():
	var party = get_party()
	
	for member in party:
		match member.partyPlace:
			1: partyMem1.swapCharacter(member)
			2: partyMem2.swapCharacter(member)
			3: partyMem3.swapCharacter(member)
			4: monster.swapCharacter(member)

func set_pause(toggle: bool):
	canPause = toggle

func get_config_setting(setting):
	return _config_file[setting]

func show_pause():
	if !paused:
		var pauseInstance = pauseScreen.instantiate()
		$CanvasLayer.add_child(pauseInstance)
		pauseInstance.showPause()

func get_game_state():
	return _GAME_STATE

func set_game_state(newState: Enums.GAME_STATE):
	_GAME_STATE = newState

func set_player_targeting(targeting):
	BATTLE_TARGETING_MODE = targeting

func get_player_character():
	return partyMem1

func get_player_camera():
	return partyMem1.get_child(0).get_child(0)

func get_active_party():
	var arr = [partyMem1]
	
	if partyMem2.active: arr.append(partyMem2)
	if partyMem3.active: arr.append(partyMem3)
	return arr

func set_party_position(coordinates: Vector3):
	partyMem1.set_position(coordinates)
	partyMem2.set_position(Vector3(coordinates.x + 0.01, coordinates.y + 0.01, coordinates.z + 0.01))
	partyMem3.set_position(Vector3(coordinates.x + 0.3, coordinates.y + 0.2, coordinates.z + 0.2))
	monster.set_position(Vector3(coordinates.x + 0.4, coordinates.y + 0.3, coordinates.z + 0.3))

func set_party_member_collision(enable: bool):
	if enable:
		partyMem2.set_collision_mask_value(2, true)
		partyMem3.set_collision_mask_value(2, true)
	else:
		partyMem2.set_collision_mask_value(2, false)
		partyMem3.set_collision_mask_value(2, false)

func get_inventory():
	return _save_file.inventory

func use_inventory_item(itemName: String):
	for item in _save_file.inventory:
		if item.item.name == itemName:
			item.amount -= 1

func remove_inventory_item(itemName: String):
	var idx = 0
	
	for item in _save_file.inventory:
		if item.item.name == itemName:
			break
		idx += 1
	
	_save_file.inventory.remove_at(idx)

# Opens a file - used in all of the handler files.
func openFile(dataFile: String):
	var file = FileAccess.open(dataFile, FileAccess.READ)
	var test_json_conv = JSON.new()
	@warning_ignore("return_value_discarded")
	test_json_conv.parse(file.get_as_text())
	var data = test_json_conv.get_data()
	return data

# Just resizes images. Currently used in ItemLists but can be extended if needed.
func imageResize(folder_path, key, size = 64):
	var texture = load("res://assets/" + folder_path + "/" + key + ".png")
	print(texture)
	var newTexture = ImageTexture.new()
	if texture != null:
		texture = texture.get_data()
		texture.resize(size, size)
		@warning_ignore("return_value_discarded", "static_called_on_instance")
		newTexture.create_from_image(texture)
	return newTexture

func checkIfStringIsInsideArray(key: String, arr: Array):
	var found = false
	for string in arr:
		if found:
			break
		else:
			if key == string:
				found = true
	return found

func printSignalError(node, functionName, signalName):
	print('SIGNAL ERROR: ' + node + '::' + functionName + ': ' + signalName + " failed, for some reason.")

# SCENE HANDLERS
func goto_scene(path):
	following_scene = path
	player.speed_scale = 2
	player.play_backwards("SceneFade")

func _deferred_goto_scene(path):
	current_scene.free()
	var s = ResourceLoader.load(path)
	
	current_scene = s.instantiate()
	
	get_tree().get_root().add_child(current_scene)
	
	player.play("SceneFade")
	print("hello")

func _on_animation_player_animation_finished(_anim_name):
	if (following_scene != ""):
		
		call_deferred("_deferred_goto_scene", following_scene)
	following_scene = ""
