extends Control

class_name EndScreen

@onready var home_button: TextureButton = $Panel/MarginContainer/HBoxContainer/HomeButton
@onready var restart_button: TextureButton = $Panel/MarginContainer/HBoxContainer/BackButton
@onready var game_over_label: Label = $Panel/MarginContainer/GameOver
@onready var lose_text: Label = $Panel/MarginContainer/LoseText
@onready var line_edit: LineEdit = $Panel/MarginContainer/LineEdit
@onready var save_manager : SaveManagerApi = SaveManager
@onready var fade : Fader = Fade

var is_win : bool = false
var game_kind : int = SaveManager.GameKind.PONG
var score : int = 0
var name_suffix : String = ""

func _ready() -> void:
	game_over_label.text = "You Won!" if is_win else "Game Over"
	line_edit.visible = is_win
	lose_text.visible = not is_win
	home_button.pressed.connect(fade._change_scene.bind(fade.main_menu))
	restart_button.pressed.connect(get_tree().reload_current_scene)
	restart_button.pressed.connect(fade._unpause_game)

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
	if _name == "":
		line_edit.editable = false
		return
	save_manager.add_high_score(game_kind, _name + name_suffix, score)
	line_edit.text = _name
	line_edit.editable = false
