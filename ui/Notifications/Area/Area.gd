extends TextureRect


@onready var areaName = $"%AreaName"
@onready var areaDescription = $"%AreaDescription"
@onready var player = $AnimationPlayer
func prepare(displayName: String, desc: String):
	areaName.text = displayName
	areaDescription.text = desc
	player.play("show")
