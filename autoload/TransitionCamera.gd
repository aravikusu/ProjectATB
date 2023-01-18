extends Camera3D

var tween: Tween

func transition(from: Camera3D, to: Camera3D, duration: float = 1.0):
	fov = from.fov
	cull_mask = from.cull_mask
	
	current = true
	
	if tween != null:
		if tween.is_running():
			tween.stop()
		else:
			global_transform = from.global_transform
	else:
		global_transform = from.global_transform
	
	tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "global_transform", to.global_transform, duration)
	tween.tween_property(self, "fov", to.fov, duration)
	
	await tween.finished
	to.current = true
