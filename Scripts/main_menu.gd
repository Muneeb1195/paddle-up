extends Control

class_name MainMenu

@onready var play: TextureButton = $VBoxContainer/Play
@onready var high_scores: TextureButton = $VBoxContainer/HighScores
const ORIG_PLAY_SIZE : Vector2 = Vector2(256,256)
const ORIG_HIGH_SIZE : Vector2 = Vector2(160,160)


func _on_play_button_down() -> void:
	_tween_button_press(play)

func _on_play_button_up() -> void:
	_tween_button_release(play,ORIG_PLAY_SIZE)

func _on_high_scores_button_down() -> void:
	_tween_button_press(high_scores)

func _on_high_scores_button_up() -> void:
	_tween_button_release(high_scores,ORIG_HIGH_SIZE)

func _tween_button_press(node : TextureButton) -> void:
	var scale_to : Vector2 = node.custom_minimum_size * 0.9
	var tween : Tween = create_tween().set_parallel(true)
	tween.tween_property(node,"custom_minimum_size",scale_to,0.1)
	tween.tween_property(node,"modulate:a", 0.8,0.1)
	tween.connect("finished",tween.kill)

func _tween_button_release(node : TextureButton, orig_size : Vector2) -> void:
	var scale_to : Vector2 = orig_size
	var tween : Tween = create_tween().set_parallel(true)
	tween.tween_property(node,"custom_minimum_size",scale_to,0.1)
	tween.tween_property(node,"modulate:a", 1.0,0.1)
	tween.connect("finished",tween.kill)
