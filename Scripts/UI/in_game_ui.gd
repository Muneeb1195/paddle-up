extends CanvasLayer

class_name InGameUI

@export var pause_menu_scene : PackedScene
@export var end_screen_scene : PackedScene

@onready var margin_container: MarginContainer = $MarginContainer
@onready var global : Globals = Global
@onready var save_manager : SaveManagerApi = SaveManager
@onready var fade : Fader = Fade
@onready var pause: Button = $MarginContainer/VBox/Pause

func _ready() -> void:
	_tween_menu(margin_container,null)
	pause.mouse_entered.connect(ButtonTweenHelper.hover_enter.bind(pause))
	pause.mouse_exited.connect(ButtonTweenHelper.hover_exit.bind(pause))

func _display_lose_screen() -> void:
	var end_screen : EndScreen = end_screen_scene.instantiate()
	end_screen.hide()
	add_child(end_screen)
	_tween_menu(end_screen,margin_container)
	await get_tree().create_timer(0.5).timeout
	fade._pause_game()

func _on_pause_pressed() -> void:
	if not find_child("LoseScreen",true,false) and not find_child("PauseMenu",true,false):
		var pause_menu : PauseMenu = pause_menu_scene.instantiate()
		pause_menu.hide()
		_tween_menu(pause_menu,margin_container)
		add_child(pause_menu)
		pause_menu.resume.pressed.connect(_resume_game)
		pause_menu.resume.pressed.connect(_tween_menu.bind(margin_container,pause_menu))
		pause_menu.resume.pressed.connect(pause_menu.queue_free)
		await get_tree().create_timer(0.5).timeout
		fade._pause_game()

func _resume_game() -> void:
	fade._unpause_game()

func _tween_menu(s_node : Control, h_node : Control) -> void:
	var tween : Tween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CIRC).set_parallel(true)
	tween.tween_callback(s_node.show)
	tween.tween_property(s_node,"modulate:a", 1.0,0.5).from(0.0)
	if h_node != null:
		tween.tween_property(h_node,"modulate:a", 0.0,0.5).from(1.0)

func _on_pause_button_down() -> void:
	ButtonTweenHelper.press(pause)

func _on_pause_button_up() -> void:
	ButtonTweenHelper.release(pause)
