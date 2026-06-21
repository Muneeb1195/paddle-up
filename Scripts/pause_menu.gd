extends Control

class_name PauseMenu

@onready var home: TextureButton = $Panel/MarginContainer/HBoxContainer/Home
@onready var restart: TextureButton = $Panel/MarginContainer/HBoxContainer/Restart
@onready var resume: TextureButton = $Panel/MarginContainer/HBoxContainer/BackButton
@onready var global : Globals = Global
@onready var fade : Fader = Fade
@onready var label: Label = $Panel/MarginContainer/Label

func _ready() -> void:
	pass

func _on_restart_pressed() -> void:
	get_tree().reload_current_scene()
	fade._unpause_game()

func _on_home_pressed() -> void:
	fade._change_scene.call_deferred(fade.main_menu)

func _on_home_button_down() -> void:
	ButtonTweenHelper.press(home)

func _on_home_button_up() -> void:
	ButtonTweenHelper.release(home, Vector2(128,128))

func _on_restart_button_down() -> void:
	ButtonTweenHelper.press(restart)

func _on_restart_button_up() -> void:
	ButtonTweenHelper.release(restart, Vector2(128,128))

func _on_back_button_button_down() -> void:
	ButtonTweenHelper.press(resume)

func _on_back_button_button_up() -> void:
	ButtonTweenHelper.release(resume, Vector2(128,128))
