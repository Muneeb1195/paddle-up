extends Control

class_name LoseScreen

@onready var home_button: TextureButton = $Panel/MarginContainer/HBoxContainer/HomeButton
@onready var restart_button: TextureButton = $Panel/MarginContainer/HBoxContainer/BackButton
@onready var h_box: HBoxContainer = $Panel/MarginContainer/HBoxContainer
@onready var game_over: Label = $Panel/MarginContainer/GameOver
@onready var lose_text: Label = $Panel/MarginContainer/LoseText
@onready var global : Globals = Global

func _ready() -> void:
	lose_text.modulate = global.color_e
	game_over.modulate = global.color_e
	h_box.modulate = global.color_d

func _on_line_edit_text_submitted(new_text: String) -> void:
	var _name : String = new_text.to_upper()
	if _name == "":
		#player_name.placeholder_text = "Enter Name!!!"
		#player_name.modulate = Color.INDIAN_RED
		pass
	else:
		#Audio.score_submit.play()
		#game_manager.high_scores.append([_name,game_manager.level_points])
		#player_name.virtual_keyboard_enabled = false
		#DisplayServer.virtual_keyboard_hide()
		#game_manager.sort_high_score()
		#player_name.editable = false
		#game_manager.save_game()
		pass

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
