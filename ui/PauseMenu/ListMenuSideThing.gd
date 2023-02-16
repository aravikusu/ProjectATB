extends MarginContainer

@onready var bigIcon = $"%BigIcon"
func setStuff(icon: Texture):
	bigIcon.texture = icon
