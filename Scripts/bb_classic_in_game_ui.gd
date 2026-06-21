extends InGameUI

class_name BBClassicInGameUi

@onready var score: Label = $MarginContainer/VBox/Score
@onready var lives: Label = $MarginContainer/VBox/HBoxContainer/Lives
@onready var level_bb_classic : LevelBbClassic = get_tree().get_first_node_in_group("LevelBBClassic")
@onready var line_edit: LineEdit = $LineEdit

func _on_lose() -> void:
	_tween_menu(line_edit, margin_container)
	_show_virtual_keyboard()
	await get_tree().create_timer(0.5).timeout
	fade._pause_game()

func _on_pause_pressed() -> void:
	level_bb_classic.set_process_input(true)
	if not line_edit.visible:
		super._on_pause_pressed()

func _on_pause_mouse_entered() -> void:
	level_bb_classic.set_process_input(false)
	level_bb_classic.trajectory_line.hide()

func _on_pause_mouse_exited() -> void:
	level_bb_classic.set_process_input(true)

func _on_line_edit_text_submitted(new_text: String) -> void:
	_hide_virtual_keyboard()
	global.bb_clas_hs.append([new_text, level_bb_classic.level])
	global.bb_clas_hs.sort_custom(func(a: Array, b: Array) -> bool: return a[1] > b[1])
	if global.bb_clas_hs.size() > 5:
		global.bb_clas_hs.resize(5)
	global.bb_clas_high_scores = {"HighScores" : global.bb_clas_hs}
	global._save_game(global.bb_clas_hs_path, global.bb_clas_high_scores)
	global.bb_clas_dict.clear()
	global._save_game(global.bb_clas_sav_path, global.bb_clas_dict)
	line_edit.text = new_text
	line_edit.hide()
	_display_lose_screen()

func _show_virtual_keyboard() -> void:
	if DisplayServer.has_feature(DisplayServer.FEATURE_VIRTUAL_KEYBOARD):
		DisplayServer.virtual_keyboard_show(line_edit.text)

func _hide_virtual_keyboard() -> void:
	if DisplayServer.has_feature(DisplayServer.FEATURE_VIRTUAL_KEYBOARD):
		DisplayServer.virtual_keyboard_hide()
