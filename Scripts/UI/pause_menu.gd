extends Control

class_name PauseMenu

@onready var home: Button = $Panel/MarginContainer/HBoxContainer/Home
@onready var restart: Button = $Panel/MarginContainer/HBoxContainer/Restart
@onready var resume: Button = $Panel/MarginContainer/HBoxContainer/BackButton
@onready var fade : Fader = Fade

func _ready() -> void:
	home.mouse_entered.connect(ButtonTweenHelper.hover_enter.bind(home))
	home.mouse_exited.connect(ButtonTweenHelper.hover_exit.bind(home))
	restart.mouse_entered.connect(ButtonTweenHelper.hover_enter.bind(restart))
	restart.mouse_exited.connect(ButtonTweenHelper.hover_exit.bind(restart))
	resume.mouse_entered.connect(ButtonTweenHelper.hover_enter.bind(resume))
	resume.mouse_exited.connect(ButtonTweenHelper.hover_exit.bind(resume))

func _on_restart_pressed() -> void:
	get_tree().reload_current_scene()
	fade._unpause_game()

func _on_home_pressed() -> void:
	fade._change_scene.call_deferred(fade.main_menu)

func _on_home_button_down() -> void:
	ButtonTweenHelper.press(home)

func _on_home_button_up() -> void:
	ButtonTweenHelper.release(home)

func _on_restart_button_down() -> void:
	ButtonTweenHelper.press(restart)

func _on_restart_button_up() -> void:
	ButtonTweenHelper.release(restart)

func _on_back_button_button_down() -> void:
	ButtonTweenHelper.press(resume)

func _on_back_button_button_up() -> void:
	ButtonTweenHelper.release(resume)
