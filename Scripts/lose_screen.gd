extends Control

class_name LoseScreen

@onready var home_button: TextureButton = $Panel/MarginContainer/HBoxContainer/HomeButton
@onready var restart_button: TextureButton = $Panel/MarginContainer/HBoxContainer/BackButton
@onready var h_box: HBoxContainer = $Panel/MarginContainer/HBoxContainer
@onready var game_over: Label = $Panel/MarginContainer/GameOver
@onready var lose_text: Label = $Panel/MarginContainer/LoseText
@onready var global : Globals = Global

func _ready() -> void:
	pass

func _on_home_button_button_down() -> void:
	ButtonTweenHelper.press(home_button)

func _on_home_button_button_up() -> void:
	ButtonTweenHelper.release(home_button, Vector2(128,128))

func _on_back_button_button_down() -> void:
	ButtonTweenHelper.press(restart_button)

func _on_back_button_button_up() -> void:
	ButtonTweenHelper.release(restart_button, Vector2(128,128))
