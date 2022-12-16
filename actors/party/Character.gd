extends AnimatedSprite2D

var _sprites := {Vector2.RIGHT: 1, Vector2.LEFT: 2, Vector2.UP: 3, Vector2.DOWN: 4}

@onready var player = $AnimationPlayer

func updateSprite(direction: Vector2):
	frame = _sprites[direction]

func changeSprite(newSprite: String):
	animation = newSprite

func showOutline():
	player.play("outline")

func hideOutline():
	player.play_backwards("outline")
