extends CanvasLayer

class_name InGameUI

@export var pause_menu_scene : PackedScene
@export var lose_screen_scene : PackedScene

@onready var margin_container: MarginContainer = $MarginContainer
@onready var global : Globals = Global
@onready var fade : Fader = Fade
@onready var pause: TextureButton = $MarginContainer/VBox/Pause

func _ready() -> void:
	margin_container.modulate = global.color_d
	_tween_menu(margin_container,null)

func _display_lose_screen() -> void:
	var lose_screen : LoseScreen = lose_screen_scene.instantiate()
	lose_screen.hide()
	add_child(lose_screen)
	_tween_menu(lose_screen,margin_container)
	fade._pause_game()
	lose_screen.home_button.pressed.connect(fade._change_scene.bind(fade.main_menu))
	lose_screen.restart_button.pressed.connect(get_tree().reload_current_scene)
	lose_screen.restart_button.pressed.connect(fade._unpause_game)

func _on_pause_pressed() -> void:
	if not find_child("LoseScreen",true,false):
		var pause_menu : PauseMenu = pause_menu_scene.instantiate()
		pause_menu.hide()
		_tween_menu(pause_menu,margin_container)
		add_child(pause_menu)
		fade._pause_game()
		pause_menu.restart.pressed.connect(_on_restart_level)
		pause_menu.resume.pressed.connect(_resume_game)
		pause_menu.resume.pressed.connect(_tween_menu.bind(margin_container,pause_menu))
		pause_menu.resume.pressed.connect(pause_menu.queue_free)

func _resume_game() -> void:
	fade._unpause_game()

func _on_restart_level() -> void:
	pass

func _tween_menu(s_node : Control, h_node : Control) -> void:
	var tween : Tween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CIRC).set_parallel(true)
	tween.tween_callback(s_node.show)
	tween.tween_property(s_node,"modulate:a", 1.0,0.5).from(0.0)
	if h_node != null:
		tween.tween_property(h_node,"modulate:a", 0.0,0.5).from(1.0)
	tween.connect("finished",tween.kill)

func _on_pause_button_down() -> void:
	var scale_to : Vector2 = pause.custom_minimum_size * 0.9
	var tween : Tween = create_tween().set_parallel(true)
	tween.tween_property(pause,"custom_minimum_size",scale_to,0.1)
	tween.tween_property(pause,"modulate:a", 0.8,0.1)
	tween.connect("finished",tween.kill)


func _on_pause_button_up() -> void:
	var scale_to : Vector2 = Vector2(100,100)
	var tween : Tween = create_tween().set_parallel(true)
	tween.tween_property(pause,"custom_minimum_size",scale_to,0.1)
	tween.tween_property(pause,"modulate:a", 1.0,0.1)
	tween.connect("finished",tween.kill)
