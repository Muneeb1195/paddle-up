extends Control

class_name PauseMenu

@onready var home: TextureButton = $Panel/MarginContainer/HBoxContainer/Home
@onready var restart: TextureButton = $Panel/MarginContainer/HBoxContainer/Restart
@onready var resume: TextureButton = $Panel/MarginContainer/HBoxContainer/BackButton
@onready var global : Globals = Global
@onready var fade : Fader = Fade
@onready var label: Label = $Panel/MarginContainer/Label

func _ready() -> void:
	label.modulate = global.color_e
	home.modulate = global.color_d
	restart.modulate = global.color_d
	resume.modulate = global.color_d

func _on_restart_pressed() -> void:
	get_tree().reload_current_scene()
	fade._unpause_game()

func _on_home_pressed() -> void:
	fade._change_scene.call_deferred(fade.main_menu)

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


func _on_home_button_down() -> void:
	_tween_button_press(home)


func _on_home_button_up() -> void:
	_tween_button_release(home)


func _on_restart_button_down() -> void:
	_tween_button_press(restart)


func _on_restart_button_up() -> void:
	_tween_button_release(restart)


func _on_back_button_button_down() -> void:
	_tween_button_press(resume)


func _on_back_button_button_up() -> void:
	_tween_button_release(resume)
