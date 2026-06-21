class_name ButtonTweenHelper

static func press(node : Control, _orig_size : Vector2 = Vector2.ZERO) -> void:
	if node.has_meta("_tween") and node.get_meta("_tween") != null:
		var old : Tween = node.get_meta("_tween") as Tween
		if old != null and old.is_valid():
			old.kill()
	var tween : Tween = node.create_tween().set_parallel(true)
	tween.tween_property(node, "scale", Vector2(0.9, 0.9), 0.1)
	tween.tween_property(node, "modulate:a", 0.8, 0.1)
	node.set_meta("_tween", tween)

static func release(node : Control, _orig_size : Vector2) -> void:
	if node.has_meta("_tween") and node.get_meta("_tween") != null:
		var old : Tween = node.get_meta("_tween") as Tween
		if old != null and old.is_valid():
			old.kill()
	var tween : Tween = node.create_tween().set_parallel(true)
	tween.tween_property(node, "scale", Vector2.ONE, 0.1)
	tween.tween_property(node, "modulate:a", 1.0, 0.1)
	node.set_meta("_tween", tween)
