extends Control

class_name DifficultyMenu

@onready var easy: Button = $VBoxContainer/Easy
@onready var medium: Button = $VBoxContainer/Medium
@onready var hard: Button = $VBoxContainer/Hard

func _ready() -> void:
	easy.mouse_entered.connect(ButtonTweenHelper.hover_enter.bind(easy))
	easy.mouse_exited.connect(ButtonTweenHelper.hover_exit.bind(easy))
	medium.mouse_entered.connect(ButtonTweenHelper.hover_enter.bind(medium))
	medium.mouse_exited.connect(ButtonTweenHelper.hover_exit.bind(medium))
	hard.mouse_entered.connect(ButtonTweenHelper.hover_enter.bind(hard))
	hard.mouse_exited.connect(ButtonTweenHelper.hover_exit.bind(hard))
