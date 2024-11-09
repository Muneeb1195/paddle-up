extends InGameUI

class_name PongUI

@export var win_screen_scene : PackedScene

@onready var cpu_points: Label = $MarginContainer/VBox/CpuPoints
@onready var player_points: Label = $MarginContainer/VBox/PlayerPoints
@onready var player: Player = get_tree().get_first_node_in_group("Player")
@onready var level_pong : LEVELPONG = get_tree().get_first_node_in_group("LevelPong")
@onready var difficulty_menu: DifficultyMenu = $DifficultyMenu

func _ready() -> void:
	_tween_menu(difficulty_menu,margin_container)
	fade._pause_game()
	margin_container.modulate = global.color_d
	difficulty_menu.easy.pressed.connect(_start_game)
	difficulty_menu.medium.pressed.connect(_start_game)
	difficulty_menu.hard.pressed.connect(_start_game)

func _start_game() -> void:
	_tween_menu(margin_container,difficulty_menu)
	fade._unpause_game()

func _display_win_screen() -> void:
	var win_screen : WinScreen = win_screen_scene.instantiate()
	win_screen.hide()
	add_child(win_screen)
	_tween_menu(win_screen,margin_container)
	fade._pause_game()
	win_screen.home_button.pressed.connect(fade._change_scene.bind(fade.main_menu))
	win_screen.restart_button.pressed.connect(get_tree().reload_current_scene)
	win_screen.restart_button.pressed.connect(fade._unpause_game)
	win_screen.line_edit.text_submitted.connect(_submit_win_score)

func _display_lose_screen() -> void:
	super._display_lose_screen()
	global.pong_hs.append(["CPU Won By", level_pong.cpu_points - level_pong.player_points])
	global.pong_hs.sort()
	if global.pong_hs.size() > 5:
			global.pong_hs.resize(5)
	global.pong_high_scores = {"HighScores" : global.pong_hs}
	global._save_game(global.pong_hs_path, global.pong_high_scores)

func _submit_win_score(new_text : String) -> void:
	global.pong_hs.append([new_text + " Won By", level_pong.player_points - level_pong.cpu_points])
	global._save_game(global.pong_hs_path, global.pong_high_scores)

func _on_pause_mouse_entered() -> void:
	player.set_process_input(false)
	player.set_physics_process(false)

func _on_pause_mouse_exited() -> void:
	player.set_process_input(true)
	player.set_physics_process(true)
