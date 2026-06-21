extends Control

class_name WinScreen

@onready var home_button: TextureButton = $Panel/MarginContainer/HBoxContainer/HomeButton
@onready var restart_button: TextureButton = $Panel/MarginContainer/HBoxContainer/BackButton
@onready var line_edit: LineEdit = $Panel/MarginContainer/LineEdit

func _on_home_button_button_down() -> void:
	ButtonTweenHelper.press(home_button)

func _on_home_button_button_up() -> void:
	ButtonTweenHelper.release(home_button, Vector2(128,128))

func _on_back_button_button_down() -> void:
	ButtonTweenHelper.press(restart_button)

func _on_back_button_button_up() -> void:
	ButtonTweenHelper.release(restart_button, Vector2(128,128))

func _on_line_edit_text_submitted(new_text: String) -> void:
	line_edit.text = new_text
	line_edit.editable = false
