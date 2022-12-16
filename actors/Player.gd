extends CharacterBody2D

@export var speed := 500

#var _velocity := Vector2.ZERO

@onready var aravix = preload("res://actors/party/Aravix.tscn")
@onready var tasty = preload("res://actors/party/Tasty.tscn")
@onready var aylik = preload("res://actors/party/Aylik.tscn")
var loadedCharacter = {}
var characterType = Enums.CHARACTER.NONE
var forcedToMove = false
var forceMoveTarget = Vector2(0, 0)

@onready var spriteAnchor = $SpriteGoesHere

func _physics_process(delta):
	if forcedToMove:
		if (delta * speed) > position.distance_to(forceMoveTarget):
			forcedToMove = false
			speed = position.distance_to(forceMoveTarget) / delta
		set_velocity((forceMoveTarget - global_position).normalized() * speed)
		move_and_slide()
	else:
		if Global.get_game_state() == Enums.GAME_STATE.ROAMING:
			var direction := Vector2(
				Input.get_action_strength("movement_right") - Input.get_action_strength("movement_left"),
				Input.get_action_strength("movement_down") - Input.get_action_strength("movement_up")
			)
			
			if direction.length() > 1.0:
				direction = direction.normalized()
			
			set_velocity(speed * direction)
			@warning_ignore(return_value_discarded)
			move_and_slide()
	Global.partyArray.push_front(self.position)
	Global.partyArray.pop_back()

func _unhandled_input(event):
	if Global.get_game_state() == Enums.GAME_STATE.ROAMING:
		if event.is_action_pressed("movement_right"):
			_update_sprite(Vector2.RIGHT)
		elif event.is_action_pressed("movement_left"):
			_update_sprite(Vector2.LEFT)
		elif event.is_action_pressed("movement_down"):
			_update_sprite(Vector2.DOWN)
		elif event.is_action_pressed("movement_up"):
			_update_sprite(Vector2.UP)

func _update_sprite(direction):
	loadedCharacter.updateSprite(direction)

func swapCharacter(player):
	var character
	match player:
		Enums.CHARACTER.ARAVIX:
			character = aravix
		Enums.CHARACTER.TASTY:
			character = tasty
		Enums.CHARACTER.AYLIK: 
			character = aylik
		_:
			character = aravix
	if loadedCharacter != {}:
		loadedCharacter.queue_free()
	var instance = character.instantiate()
	spriteAnchor.add_child(instance)
	loadedCharacter = instance
	characterType = player

func flush():
	loadedCharacter.queue_free()
	loadedCharacter = {}
	characterType = Enums.CHARACTER.NONE

func forceMove(location):
	forcedToMove = true
	forceMoveTarget = location
