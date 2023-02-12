extends MarginContainer

@onready var location = $"%Location"
func _ready():
	var currentLocation = Global.get_last_location().capitalize()
	location.text = currentLocation + "..."
