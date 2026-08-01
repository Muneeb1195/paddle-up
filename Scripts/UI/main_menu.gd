extends Control

class_name MainMenu

@onready var play: TextureButton = $VBoxContainer/Play
@onready var high_scores: TextureButton = $VBoxContainer/HighScores
@onready var version_label: Label = $VersionLabel

func _ready() -> void:
	version_label.text = "v" + str(ProjectSettings.get_setting("application/config/version"))
	play.mouse_entered.connect(ButtonTweenHelper.hover_enter.bind(play))
	play.mouse_exited.connect(ButtonTweenHelper.hover_exit.bind(play))
	high_scores.mouse_entered.connect(ButtonTweenHelper.hover_enter.bind(high_scores))
	high_scores.mouse_exited.connect(ButtonTweenHelper.hover_exit.bind(high_scores))


func _on_play_button_down() -> void:
	ButtonTweenHelper.press(play)

func _on_play_button_up() -> void:
	ButtonTweenHelper.release(play)

func _on_high_scores_button_down() -> void:
	ButtonTweenHelper.press(high_scores)

func _on_high_scores_button_up() -> void:
	ButtonTweenHelper.release(high_scores)
