extends Label3D

var p0 = Vector3.ZERO
var p1 = Vector3.ZERO
var p2 = Vector3.ZERO
var t: float = 0

var fading = false

@onready var player = $AnimationPlayer
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

func prepare(start: Vector3, value: int, direction: String):
	text = str(value)
	p0 = start
	if direction == "right":
		p2 = Vector3(start.x + 0.5, start.y, start.z)
	else:
		p2 = Vector3(start.x - 0.5, start.y, start.z)
	p1 = Vector3((p0.x + p2.x) / 2 , ((p0.y + p2.y) / 2) + 1, (p0.z + p2.z) / 2)

func _on_animation_player_animation_finished(_anim_name):
	queue_free()
