extends InGameUI

class_name BBModInGameUi

@onready var level: Label = $MarginContainer/VBox/Level
@onready var time: Label = $MarginContainer/VBox/Time
@onready var level_bb_modern : LEVELBBMODERN = get_tree().get_first_node_in_group(&"LevelBBModern")
@onready var balls : BallsBB = get_tree().get_first_node_in_group(&"BallsBB")
@onready var line_edit: LineEdit = $LineEdit
@onready var retrieve_balls: Button = $MarginContainer/RetrieveBalls

var _pulse_tween : Tween

func _on_lose() -> void:
	global.bb_mod_dict.clear()
	global._save_game(global.bb_mod_sav_path,global.bb_mod_dict)
	_tween_menu(line_edit, margin_container)
	_show_virtual_keyboard()
	await get_tree().create_timer(0.5).timeout
	fade._pause_game()

func _on_pause_mouse_entered() -> void:
	level_bb_modern.set_process_input(false)
	level_bb_modern.trajectory_line.hide()

func _on_pause_mouse_exited() -> void:
	level_bb_modern.set_process_input(true)

func _on_line_edit_text_submitted(new_text: String) -> void:
	_hide_virtual_keyboard()
	global.bb_mod_hs.append([new_text,level_bb_modern.level])
	global.bb_mod_hs.sort()
	if global.bb_mod_hs.size() > 5:
		global.bb_mod_hs.resize(5)
	global.bb_mod_high_scores = {"HighScores" : global.bb_mod_hs}
	global._save_game(global.bb_mod_hs_path, global.bb_mod_high_scores)
	line_edit.text = new_text
	line_edit.hide()
	_display_lose_screen()

func _on_retrieve_balls_pressed() -> void:
	retrieve_balls.disabled = true
	if _pulse_tween:
		_pulse_tween.kill()
		retrieve_balls.scale = Vector2.ONE
	level_bb_modern.balls.retrieve_all_balls()
	_show_toast("Balls retrieved!")

func _show_virtual_keyboard() -> void:
	if DisplayServer.has_feature(DisplayServer.FEATURE_VIRTUAL_KEYBOARD):
		DisplayServer.virtual_keyboard_show(line_edit.text)

func _hide_virtual_keyboard() -> void:
	if DisplayServer.has_feature(DisplayServer.FEATURE_VIRTUAL_KEYBOARD):
		DisplayServer.virtual_keyboard_hide()

func _show_toast(text: String) -> void:
	var toast : Label = Label.new()
	toast.text = text
	toast.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	toast.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	toast.position = Vector2(300, 1800)
	toast.size = Vector2(400, 60)
	toast.modulate.a = 0.0
	toast.add_theme_font_size_override("font_size", 36)
	add_child(toast)
	var tween : Tween = create_tween()
	tween.tween_property(toast, "modulate:a", 1.0, 0.2)
	tween.tween_interval(1.0)
	tween.tween_property(toast, "modulate:a", 0.0, 0.3)
	tween.tween_callback(toast.queue_free)
