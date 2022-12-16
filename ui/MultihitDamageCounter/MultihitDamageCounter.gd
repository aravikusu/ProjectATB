extends Control


@onready var hitsLabel = $"%Hits"
@onready var damageLabel = $"%Damage"
@onready var player = $AnimationPlayer

func prepare(hits: int, damage: int):
	hitsLabel.text = str(hits)
	damageLabel.text = str(damage)
	player.play("show")
