extends Control

@onready var update = preload("res://ui/Notifications/Update/Update.tscn")

@onready var updates = $"%Updates"
@onready var area = $"%Area"

func addUpdateNotification(text: String):
	var instance = update.instantiate()
	updates.add_child(instance)
	instance.prepare(text)

func showAreaNotification(areaName: String, areaDescription: String):
	area.prepare(areaName, areaDescription)
