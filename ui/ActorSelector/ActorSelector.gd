extends Node3D

var reverse = false

@export var color: Color = Color("#FFFFFF")

@onready var sprite = $Sprite3D
@onready var timer = $Timer
# Called when the node enters the scene tree for the first time.
func _ready():
	bob()

func _process(_delta):
	sprite.modulate = color

func bob():
	var tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	if reverse:
		tween.tween_property(sprite, "position", Vector3(0, 0.05, 0), 1)
	else:
		tween.tween_property(sprite, "position", Vector3(0, -0.05, 0), 1)
	
	reverse = !reverse

func forcePos(location: Vector3):
	global_position = location

func move(location: Vector3):
	var tween = create_tween().set_Trans(Tween.TRANS_QUAD)
