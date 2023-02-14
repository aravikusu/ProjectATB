extends MarginContainer

@onready var soundContainer = $"%SoundContainer".get_child(0).get_children()
@onready var graphicsContainer = $"%GraphicsContainer".get_child(0).get_children()
@onready var gameplayContainer = $"%GameplayContainer".get_child(0).get_children()

var settings: Dictionary
var allSettings = []
var idx = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	settings = Global.get_config()
	allSettings.append_array(soundContainer)
	allSettings.append_array(graphicsContainer)
	allSettings.append_array(gameplayContainer)
	setValues()

func handle_inputs():
	if Input.is_action_just_pressed("ui_down"):
		allSettings[idx].get_child(0).altInactivate()
		if idx + 1 >= allSettings.size():
			idx = 0
		else:
			idx += 1
	if Input.is_action_just_pressed("ui_up"):
		allSettings[idx].get_child(0).altInactivate()
		if idx - 1 < 0:
			idx = allSettings.size() - 1
		else:
			idx -= 1
	if idx < 4:
		# We handle all volume sliders in here.
		incrementSlider()
	adjustMultiSelector()

func incrementSlider():
	var slider = allSettings[idx].get_child(1)
	if Input.is_action_pressed("ui_right"):
		slider.value += 1
		updateValue(slider.value, idx)
	if Input.is_action_pressed("ui_left"):
		slider.value -= 1
		updateValue(slider.value, idx)

func adjustMultiSelector():
	allSettings[4].get_child(1).isActive = false
	allSettings[5].get_child(1).isActive = false
	allSettings[6].get_child(1).isActive = false
	allSettings[7].get_child(1).isActive = false
	if idx > 3:
		allSettings[idx].get_child(1).isActive = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	handle_inputs()
	allSettings[idx].get_child(0).activate()

func setValues():
	allSettings[0].get_child(1).value = settings.music
	allSettings[1].get_child(1).value = settings.sfx
	allSettings[2].get_child(1).value = settings.voices
	allSettings[3].get_child(1).value = settings.ambiance
	allSettings[4].get_child(1).forceSet(settings.resolution)
	allSettings[5].get_child(1).forceSet(settings.aa)
	allSettings[6].get_child(1).forceSet(settings.vsync)
	allSettings[7].get_child(1).forceSet(settings.atb)

func receiveMultiSelectorValue(selector: Object, value: int):
	match selector.name:
		"ResolutionOptions": settings.resolution = value
		"AAOptions": settings.aa = value
		"VSyncOptions": settings.vsync = value
		"ATBOptions": settings.atb = value
	saveValues()

func updateValue(value, idx):
	match idx:
		0: settings.music = value
		1: settings.sfx = value
		2: settings.voices = value
		3: settings.ambiance = value
		4: settings.resolution = value
		5: settings.aa = value
		6: settings.vsync = value
		7: settings.atb = value
	saveValues()

func saveValues():
	Global.update_config(settings)
