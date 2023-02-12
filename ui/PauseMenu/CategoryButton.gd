extends Label

func activate():
	modulate = Color("#ffd78d")
	label_settings.font_size = 20

func inactivate():
	modulate = Color("#ffffffc8")
	label_settings.font_size = 15
