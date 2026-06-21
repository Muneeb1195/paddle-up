extends Control

class_name WinScreen

@onready var home_button: TextureButton = $Panel/MarginContainer/HBoxContainer/HomeButton
@onready var restart_button: TextureButton = $Panel/MarginContainer/HBoxContainer/BackButton
@onready var line_edit: LineEdit = $Panel/MarginContainer/LineEdit
@onready var global : Globals = Global

var in_game_ui : InGameUI

func _on_home_button_button_down() -> void:
	ButtonTweenHelper.press(home_button)

func _on_home_button_button_up() -> void:
	ButtonTweenHelper.release(home_button, Vector2(128,128))

func _on_back_button_button_down() -> void:
	ButtonTweenHelper.press(restart_button)

func _on_back_button_button_up() -> void:
	ButtonTweenHelper.release(restart_button, Vector2(128,128))

func _on_line_edit_text_submitted(new_text: String) -> void:
	var _name : String = new_text.to_upper()
	if _name != "":
		if in_game_ui is PongUI:
			global.pong_hs.append([_name + " Won By", in_game_ui.level_pong.player_points - in_game_ui.level_pong.cpu_points])
			global.pong_hs.sort()
			if global.pong_hs.size() > 5:
				global.pong_hs.resize(5)
			global.pong_high_scores = {"HighScores": global.pong_hs}
			global._save_game(global.pong_hs_path, global.pong_high_scores)
		line_edit.text = _name
	line_edit.editable = false
