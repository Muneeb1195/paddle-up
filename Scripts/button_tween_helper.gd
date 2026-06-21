class_name ButtonTweenHelper

static func press(node : Control, orig_size : Vector2 = Vector2.ZERO) -> void:
	var scale_to : Vector2 = node.custom_minimum_size * 0.9
	var tween : Tween = node.create_tween().set_parallel(true)
	tween.tween_property(node, "custom_minimum_size", scale_to, 0.1)
	tween.tween_property(node, "modulate:a", 0.8, 0.1)

static func release(node : Control, orig_size : Vector2) -> void:
	var tween : Tween = node.create_tween().set_parallel(true)
	tween.tween_property(node, "custom_minimum_size", orig_size, 0.1)
	tween.tween_property(node, "modulate:a", 1.0, 0.1)
