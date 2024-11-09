extends InGameUI

class_name BBClassicInGameUi

@onready var score: Label = $MarginContainer/VBox/Score
@onready var lives: Label = $MarginContainer/VBox/HBoxContainer/Lives
@onready var level_bb_classic : LEVELBBCLASSIC = get_tree().get_first_node_in_group("LevelBBClassic")
@onready var line_edit: LineEdit = $LineEdit

func _on_lose() -> void:
	fade._pause_game()
	_tween_menu(line_edit, margin_container)
	global.bb_clas_dict.clear()

func _on_pause_pressed() -> void:
	if not line_edit.visible:
		super._on_pause_pressed()

func _on_restart_level() -> void:
	global.bb_clas_dict.clear()

func _on_pause_mouse_entered() -> void:
	level_bb_classic.set_process_input(false)
	level_bb_classic.trajectory_line.hide()


func _on_pause_mouse_exited() -> void:
	level_bb_classic.set_process_input(true)


func _on_line_edit_text_submitted(new_text: String) -> void:
	global.bb_clas_hs.append([new_text,level_bb_classic.level])
	global.bb_clas_hs.sort()
	if global.bb_clas_hs.size() > 5:
		global.bb_mod_hs.resize(5)
	global.bb_clas_high_scores = {"HighScores" : global.bb_clas_hs}
	global._save_game(global.bb_clas_hs_path, global.bb_clas_high_scores)
	line_edit.text = new_text
	line_edit.hide()
	_display_lose_screen()
