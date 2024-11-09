extends Control

class_name WinScreen

@onready var home_button: TextureButton = $Panel/MarginContainer/HBoxContainer/HomeButton
@onready var restart_button: TextureButton = $Panel/MarginContainer/HBoxContainer/BackButton
@onready var line_edit: LineEdit = $Panel/MarginContainer/LineEdit

func _tween_button_press(node : TextureButton) -> void:
	var scale_to : Vector2 = node.custom_minimum_size * 0.9
	var tween : Tween = create_tween().set_parallel(true)
	tween.tween_property(node,"custom_minimum_size",scale_to,0.1)
	tween.tween_property(node,"modulate:a", 0.8,0.1)
	tween.connect("finished",tween.kill)

func _tween_button_release(node : TextureButton) -> void:
	var scale_to : Vector2 = Vector2(128,128)
	var tween : Tween = create_tween().set_parallel(true)
	tween.tween_property(node,"custom_minimum_size",scale_to,0.1)
	tween.tween_property(node,"modulate:a", 1.0,0.1)
	tween.connect("finished",tween.kill)

func _on_home_button_button_down() -> void:
	_tween_button_press(home_button)


func _on_home_button_button_up() -> void:
	_tween_button_release(home_button)


func _on_back_button_button_down() -> void:
	_tween_button_press(restart_button)


func _on_back_button_button_up() -> void:
	_tween_button_release(restart_button)


func _on_line_edit_text_submitted(new_text: String) -> void:
	line_edit.text = new_text
	line_edit.editable = false
