extends Control

class_name HighScores

@onready var v_box: VBoxContainer = $Panel/MarginContainer/VBoxContainer
@onready var back_button: TextureButton = $Panel/MarginContainer/HBoxContainer/BackButton
@onready var global : Globals = Global
@onready var pong: Button = $HBoxContainer/Pong
@onready var brick_breaker: Button = $HBoxContainer/BrickBreaker
@onready var ball_breaker: Button = $HBoxContainer/BallBreaker

func _on_back_button_button_down() -> void:
	var scale_to : Vector2 = back_button.custom_minimum_size * 0.9
	var tween : Tween = create_tween().set_parallel(true)
	tween.tween_property(back_button,"custom_minimum_size",scale_to,0.1)
	tween.tween_property(back_button,"modulate:a", 0.8,0.1)
	tween.connect("finished",tween.kill)

func _on_back_button_button_up() -> void:
	var scale_to : Vector2 = Vector2(128,128)
	var tween : Tween = create_tween().set_parallel(true)
	tween.tween_property(back_button,"custom_minimum_size",scale_to,0.1)
	tween.tween_property(back_button,"modulate:a", 1.0,0.1)
	tween.connect("finished",tween.kill)

func _on_pong_pressed() -> void:
	_disable_buttons()
	_display_scores(global.pong_hs)

func _on_brick_breaker_pressed() -> void:
	_disable_buttons()
	_display_scores(global.bb_clas_hs)

func _on_ball_breaker_pressed() -> void:
	_disable_buttons()
	_display_scores(global.bb_mod_hs)

func _disable_buttons() -> void:
	pong.disabled = true
	brick_breaker.disabled = true
	ball_breaker.disabled = true

func _enable_buttons() -> void:
	pong.disabled = false
	brick_breaker.disabled = false
	ball_breaker.disabled = false

func _display_scores(score_array : Array) -> void:
	if v_box.get_child_count() >= 0:
		_hide_scores()
	for i : int in score_array.size():
		var label : Label = Label.new()
		var h_s_arr : Array = score_array[i]
		var tween : Tween = create_tween()
		label.modulate.a = 0.0
		label.text = "%2d." % [i+1] + h_s_arr[0] + "   %02d   " % [h_s_arr[1]]
		label.label_settings = LabelSettings.new()
		label.label_settings.font_size = 42
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		v_box.add_child(label)
		tween.tween_property(label, "modulate:a", 1.0, 0.25)
		await tween.finished
		tween.kill()
	_enable_buttons()

func _hide_scores() -> void:
	for label : Label in v_box.get_children():
		var tween : Tween = create_tween()
		tween.tween_property(label, "modulate:a", 0.0, 0.25)
		tween.tween_callback(label.queue_free)
		await tween.finished
		tween.kill()
