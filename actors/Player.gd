extends CharacterBody3D

var speed := 3.0
var gravity := 2.0

var _velocity := Vector3.ZERO

@onready var aravix = preload("res://actors/party/Aravix.tscn")
@onready var tasty = preload("res://actors/party/Tasty.tscn")
@onready var aylik = preload("res://actors/party/Aylik.tscn")
var loadedCharacter = {}
var characterType = Enums.CHARACTER.NONE
var forcedToMove = false
var forceMoveTarget = Vector3(0, 0, 0)

@onready var spriteViewport = $"%SpriteViewport"
@onready var collision = $CollisionShape3d

func handle_input() -> Vector3:
	var input = Vector3()
	
	if Input.is_action_pressed("movement_up"):
		input.z -= 1
	if Input.is_action_pressed("movement_down"):
		input.z += 1
	if Input.is_action_pressed("movement_left"):
		input.x -= 1
	if Input.is_action_pressed("movement_right"):
		input.x += 1
	
	return input

func _physics_process(delta):
	if forcedToMove:
		if (delta * speed) > position.distance_to(forceMoveTarget):
			forcedToMove = false
			speed = position.distance_to(forceMoveTarget) / delta
		set_velocity((forceMoveTarget - global_position).normalized() * speed)
		move_and_slide()
	else:
		if Global.get_game_state() == Enums.GAME_STATE.ROAMING:
			_velocity.x = 0
			_velocity.z = 0
			var input = handle_input()
			input = input.normalized()
			#var direction = (transform.basis.z * input.z + transform.basis.x * input.x)
			
			_velocity.x = input.x * speed
			_velocity.z = input.z * speed
			
			if not is_on_floor():
				_velocity.y -= gravity * delta
			
			set_velocity(_velocity)
			@warning_ignore(return_value_discarded)
			move_and_slide()
			Global.partyArray.push_front(self.position)
			Global.partyArray.pop_back()

func _unhandled_input(event):
	# Ignore this for now
	if 1 == 2:
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
	spriteViewport.add_child(instance)
	loadedCharacter = instance
	characterType = player

func flush():
	loadedCharacter.queue_free()
	loadedCharacter = {}
	characterType = Enums.CHARACTER.NONE

func toggleCollision():
	collision.set_deferred("disabled", !collision.disabled)

func forceMove(location):
	forcedToMove = true
	forceMoveTarget = location
