extends CharacterBody3D

# Used to store get the actual stats and abilities of said enemy.
@export var displayName := ""
@export var stats: Stats
var playerControlled = false
var forcedToMove = false
var forceMoveTarget = Vector3(0, 0, 0)

var speed := 3.0
var gravity := 2.0

var commands = []
var ATB = 0
var CHARACTER_BATTLE_STATE = Enums.CHARACTER_BATTLE_STATE.CHARGING
var currentSprite = "overworld"
var hitboxRadius = 0

var showOutline = false

@onready var player = $AnimationPlayer
@onready var sprite = $"%Sprite"

func _ready():
	commands = EnemyHelper.getEnemyCommands(displayName)
	hitboxRadius = $CollisionShape3D.shape.radius

func _physics_process(delta):
	if forcedToMove:
		if (delta * speed) > position.distance_to(forceMoveTarget):
			forcedToMove = false
			speed = position.distance_to(forceMoveTarget) / delta
		set_velocity((forceMoveTarget - global_position).normalized() * speed)
		move_and_slide()

func setOverworldSprite():
	if currentSprite != "overworld":
		currentSprite = "overworld"
		sprite.animation = "overworld"

func setReadySprite():
	if currentSprite != "ready":
		currentSprite = "ready"
		sprite.animation = "ready"

func setDeadSprite():
	if currentSprite != "dead":
		currentSprite = "dead"
		sprite.animation = "dead"

# All actors have their own dead animation... play it
func playDeadAnimation():
	player.play("dead")

func getHeight():
	var height = sprite.sprite_frames.get_frame_texture("overworld", 0).get_height()
	return height * sprite.pixel_size

func forceMove(location):
	forcedToMove = true
	forceMoveTarget = location
