extends Label

@export var fontSize = 20

func _ready():
	var labelSettings = LabelSettings.new()
	labelSettings.font_size = fontSize
	labelSettings.outline_size = 5
	labelSettings.outline_color = Color("#000")
	label_settings = labelSettings

func activate():
	modulate = Color("#ffd78d")
	label_settings.font_size = fontSize

func inactivate():
	modulate = Color("#ffffffc8")
	label_settings.font_size = fontSize - 5

func altInactivate():
	modulate = Color("#ffffff")
