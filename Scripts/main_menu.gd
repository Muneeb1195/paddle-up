extends Control

class_name MainMenu

@onready var play: TextureButton = $VBoxContainer/Play
@onready var high_scores: TextureButton = $VBoxContainer/HighScores
const ORIG_PLAY_SIZE : Vector2 = Vector2(256,256)
const ORIG_HIGH_SIZE : Vector2 = Vector2(160,160)


func _on_play_button_down() -> void:
	ButtonTweenHelper.press(play)

func _on_play_button_up() -> void:
	ButtonTweenHelper.release(play, ORIG_PLAY_SIZE)

func _on_high_scores_button_down() -> void:
	ButtonTweenHelper.press(high_scores)

func _on_high_scores_button_up() -> void:
	ButtonTweenHelper.release(high_scores, ORIG_HIGH_SIZE)
