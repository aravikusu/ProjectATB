extends Label

func _ready():
	var labelSettings = LabelSettings.new()
	labelSettings.font_size = 20
	labelSettings.outline_size = 5
	labelSettings.outline_color = Color("#000")
	label_settings = labelSettings

func activate():
	modulate = Color("#ffd78d")
	label_settings.font_size = 20

func inactivate():
	modulate = Color("#ffffffc8")
	label_settings.font_size = 15

func altInactivate():
	modulate = Color("#ffffff")
