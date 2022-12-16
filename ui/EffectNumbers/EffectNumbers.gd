extends Control

var p0 = Vector2.ZERO
var p1 = Vector2.ZERO
var p2 = Vector2.ZERO
var t: float = 0

var fading = false

@onready var player = $AnimationPlayer
@onready var label = $"%Label"
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if position != p2:
		t += delta * 0.8
		var q0 = p0.lerp(p1, t)
		var q1 = p1.lerp(p2, t)
		position = q0.lerp(q1, t)
	
	if t > 0.6 && !fading:
		fading = true
		player.play("fade")

func prepare(start: Vector2, value: int, direction: String):
	label.text = str(value)
	p0 = start
	if direction == "right":
		p2 = Vector2(start.x + 100, start.y)
	else:
		p2 = Vector2(start.x - 100, start.y)
	p1 = Vector2((p0.x + p2.x) / 2, ((p0.y + p2.y) / 2) - 200)

func _on_animation_player_animation_finished(_anim_name):
	queue_free()
