extends Control

class_name HighScores

@onready var v_box: VBoxContainer = $Panel/MarginContainer/VBoxContainer
@onready var back_button: Button = $Panel/MarginContainer/HBoxContainer/BackButton
@onready var save_manager : SaveManagerApi = SaveManager
@onready var pong: Button = $HBoxContainer/Pong
@onready var brick_breaker: Button = $HBoxContainer/BrickBreaker
@onready var ball_breaker: Button = $HBoxContainer/BallBreaker

var _shared_settings : LabelSettings = LabelSettings.new()

func _ready() -> void:
	_shared_settings.font_size = 42
	pong.mouse_entered.connect(ButtonTweenHelper.hover_enter.bind(pong))
	pong.mouse_exited.connect(ButtonTweenHelper.hover_exit.bind(pong))
	brick_breaker.mouse_entered.connect(ButtonTweenHelper.hover_enter.bind(brick_breaker))
	brick_breaker.mouse_exited.connect(ButtonTweenHelper.hover_exit.bind(brick_breaker))
	ball_breaker.mouse_entered.connect(ButtonTweenHelper.hover_enter.bind(ball_breaker))
	ball_breaker.mouse_exited.connect(ButtonTweenHelper.hover_exit.bind(ball_breaker))
	back_button.mouse_entered.connect(ButtonTweenHelper.hover_enter.bind(back_button))
	back_button.mouse_exited.connect(ButtonTweenHelper.hover_exit.bind(back_button))

func _on_back_button_button_down() -> void:
	ButtonTweenHelper.press(back_button)

func _on_back_button_button_up() -> void:
	ButtonTweenHelper.release(back_button, Vector2(128,128))

func _on_pong_pressed() -> void:
	_disable_buttons()
	_display_scores(save_manager.get_high_scores(SaveManager.GameKind.PONG))

func _on_brick_breaker_pressed() -> void:
	_disable_buttons()
	_display_scores(save_manager.get_high_scores(SaveManager.GameKind.BB_CLASSIC))

func _on_ball_breaker_pressed() -> void:
	_disable_buttons()
	_display_scores(save_manager.get_high_scores(SaveManager.GameKind.BB_MODERN))

func _disable_buttons() -> void:
	pong.disabled = true
	brick_breaker.disabled = true
	ball_breaker.disabled = true

func _enable_buttons() -> void:
	pong.disabled = false
	brick_breaker.disabled = false
	ball_breaker.disabled = false

func _display_scores(score_array : Array) -> void:
	if v_box.get_child_count() > 0:
		await _hide_scores()
	for i : int in score_array.size():
		var label : Label = Label.new()
		var h_s_arr : Array = score_array[i] as Array
		if h_s_arr.size() < 2:
			continue
		var tween : Tween = create_tween()
		label.modulate.a = 0.0
		label.text = "%2d." % [i+1] + h_s_arr[0] + "   %02d   " % [h_s_arr[1]]
		label.label_settings = _shared_settings
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
