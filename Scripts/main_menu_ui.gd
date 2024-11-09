extends CanvasLayer

class_name MainUI

@onready var main_menu: MainMenu = $Control/MarginContainer/MainMenu
@onready var games : Games = $Control/MarginContainer/Games
@onready var high_score: HighScores = $Control/MarginContainer/HighScore
@onready var fade : Fader = Fade
@onready var control: Control = $Control
@onready var global : Globals = Global
@onready var menus : Array = [main_menu,games,high_score]

func _ready() -> void:
	main_menu.modulate = global._choose_color()
	high_score.modulate = global.color_d
	games.back.modulate = global.color_d
	_tween_menu(main_menu)
	
	# main menu buttons
	main_menu.play.pressed.connect(_display_games)
	#main_menu.play.pressed.connect(Fade._fade_to_black)
	main_menu.high_scores.pressed.connect(_display_high_scores)
	#main_menu.high_scores.pressed.connect(Fade._fade_to_black)
	
	#high Score button
	high_score.back_button.pressed.connect(_display_main_menu)
	#high_score.back_button.pressed.connect(Fade._fade_to_normal)
	
	#games button
	games.pong.pressed.connect(fade._change_scene.bind(fade.pong))
	games.bb_classic.pressed.connect(fade._change_scene.bind(fade.bb_classic))
	games.bb_modern.pressed.connect(fade._change_scene.bind(fade.bb_modern))
	games.back.pressed.connect(_display_main_menu)
	#games.back.pressed.connect(Fade._fade_to_normal)


func _display_main_menu() -> void:
	#Audio.tap.pitch_scale = randf_range(0.85,1.0)
	#Audio.tap.play()
	_tween_menu(main_menu)

func _display_high_scores() -> void:
	#Audio.tap.pitch_scale = randf_range(0.85,1.0)
	#Audio.tap.play()
	_tween_menu(high_score)

func _display_games() -> void:
	_tween_menu(games)

func _tween_menu(s_node : Control) -> void:
	for menu : Control in menus:
		if menu.visible:
			menu.hide()
	
	var tween : Tween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CIRC)
	tween.tween_callback(s_node.show)
	tween.tween_property(s_node,"modulate:a", 1.0,0.5).from(0.0)
	tween.connect("finished",tween.kill)
