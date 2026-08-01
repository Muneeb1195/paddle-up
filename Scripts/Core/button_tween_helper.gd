class_name ButtonTweenHelper

static func press(node : Control) -> void:
	_kill_tween(node)
	_center_pivot(node)
	var tween : Tween = node.create_tween().set_parallel(true)
	tween.tween_property(node, "scale", Vector2(0.9, 0.9), 0.1)
	tween.tween_property(node, "modulate:a", 0.8, 0.1)
	node.set_meta("_tween", tween)
	var audio_manager : Audio = AudioManager
	if audio_manager != null and audio_manager.button_press != null and not audio_manager.button_press.playing:
		audio_manager.button_press.play()

static func release(node : Control) -> void:
	_kill_tween(node)
	_center_pivot(node)
	var tween : Tween = node.create_tween().set_parallel(true)
	tween.tween_property(node, "scale", Vector2.ONE, 0.1)
	tween.tween_property(node, "modulate:a", 1.0, 0.1)
	node.set_meta("_tween", tween)

static func hover_enter(node : Control) -> void:
	_kill_tween(node)
	_center_pivot(node)
	var tween : Tween = node.create_tween().set_parallel(true)
	tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "scale", Vector2(1.06, 1.06), 0.2)
	node.set_meta("_tween", tween)

static func hover_exit(node : Control) -> void:
	_kill_tween(node)
	_center_pivot(node)
	var tween : Tween = node.create_tween().set_parallel(true)
	tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "scale", Vector2.ONE, 0.15)
	node.set_meta("_tween", tween)

static func _center_pivot(node : Control) -> void:
	node.pivot_offset = node.size / 2.0

static func _kill_tween(node : Control) -> void:
	if node.has_meta("_tween") and node.get_meta("_tween") != null:
		var old : Tween = node.get_meta("_tween") as Tween
		if old != null and old.is_valid():
			old.kill()
