extends Control

@onready var notification = preload("res://ui/NotificationCenter/Notification.tscn")

@onready var rewards = $"%Rewards"

func addRewardNotification(text: String):
	var instance = notification.instantiate()
	rewards.add_child(instance)
	instance.prepareReward(text)
