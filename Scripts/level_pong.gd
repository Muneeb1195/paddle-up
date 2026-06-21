extends Node2D

class_name LEVELPONG

enum DIFFICULTY {Easy,Medium,Hard}
@export var difficulty : DIFFICULTY

@onready var pong_table: PONGTABLE = $PongTable
@onready var player: Player = $Player
@onready var ball: Ball = $Ball
@onready var enemy: CPU = $Enemy
@onready var global : Globals = Global
@onready var pong_in_game_ui: PongUI = $PongInGameUI

const max_points : int = 11
var _cpu_points : int = 0
var cpu_points : int:
	get :
		return _cpu_points
	set(value):
		_cpu_points = value
		pong_in_game_ui.cpu_points.text = "CPU: %2d" % [_cpu_points]
		_flash_score(true)
		if _cpu_points >= max_points:
			pong_in_game_ui._display_lose_screen()
var _player_points : int = 0
var player_points : int :
	get :
		return _player_points
	set(value):
		_player_points = value
		pong_in_game_ui.player_points.text = "You: %2d" % [_player_points]
		_flash_score(false)
		if _player_points >= max_points:
			pong_in_game_ui._display_win_screen()

var ball_starting_speed : int
var _rally_count : int = 0
var _base_speed_mod : int = 0
var _countdown_active : bool = false

const INCREMENT : int = 1
const BASE_SPEED_MODS : Array[int] = [40, 45, 50]

func _ready() -> void:
	pong_table.wall.modulate = global._choose_color()
	pong_in_game_ui.difficulty_menu.easy.pressed.connect(_on_easy_pressed)
	pong_in_game_ui.difficulty_menu.medium.pressed.connect(_on_medium_pressed)
	pong_in_game_ui.difficulty_menu.hard.pressed.connect(_on_hard_pressed)
	ball.pong_rally_hit.connect(_on_rally_hit)

func _on_easy_pressed() -> void:
	difficulty = DIFFICULTY.Easy
	_set_difficulty_state()

func _on_medium_pressed() -> void:
	difficulty = DIFFICULTY.Medium
	_set_difficulty_state()

func _on_hard_pressed() -> void:
	difficulty = DIFFICULTY.Hard
	_set_difficulty_state()

func _set_difficulty_state() -> void:
	match difficulty:
		DIFFICULTY.Easy:
			ball_starting_speed = 400
			_base_speed_mod = BASE_SPEED_MODS[0]
		DIFFICULTY.Medium:
			ball_starting_speed = 500
			_base_speed_mod = BASE_SPEED_MODS[1]
		DIFFICULTY.Hard:
			ball_starting_speed = 600
			_base_speed_mod = BASE_SPEED_MODS[2]
	_apply_score_adjustments()
	_start_countdown()

func _apply_score_adjustments() -> void:
	var diff : int = _player_points - _cpu_points
	if diff <= -5:
		ball_starting_speed -= 50
	elif diff <= -3:
		ball_starting_speed -= 25

func _start_countdown() -> void:
	_countdown_active = true
	ball.hide()
	ball.set_process(false)
	ball.velocity = Vector2.ZERO
	ball.global_position = ball.original_position
	enemy.configure(int(difficulty), _rally_count)

	pong_in_game_ui.show_countdown("3")
	await get_tree().create_timer(0.8).timeout
	pong_in_game_ui.show_countdown("2")
	await get_tree().create_timer(0.8).timeout
	pong_in_game_ui.show_countdown("1")
	await get_tree().create_timer(0.8).timeout
	pong_in_game_ui.hide_countdown()
	_countdown_active = false

	ball.show()
	ball.set_process(true)
	ball.speed = ball_starting_speed
	await get_tree().create_timer(0.5).timeout
	ball._pong_start(randf() < 0.5)

func _on_rally_hit() -> void:
	_rally_count += 1
	var speed_increase : int = maxi(_base_speed_mod - (_rally_count * 2), 15)
	ball.speed += speed_increase
	enemy.configure(int(difficulty), _rally_count)
	pong_in_game_ui.update_rally(_rally_count)
	pong_in_game_ui.update_speed_indicator(ball.speed, ball_starting_speed)

func _on_goal_scored(is_cpu : bool) -> void:
	_rally_count = 0
	pong_in_game_ui.update_rally(0)
	pong_in_game_ui.update_speed_indicator(ball_starting_speed, ball_starting_speed)

func _move_ball_back() -> void:
	ball.hide()
	ball.set_process(false)
	ball.velocity = Vector2.ZERO
	ball.global_position = ball.original_position
	_start_countdown()

func _increase_player_point() -> void:
	_on_goal_scored(false)
	player_points += INCREMENT
	_move_ball_back()

func _increase_cpu_point() -> void:
	_on_goal_scored(true)
	cpu_points += INCREMENT
	_move_ball_back()

func _flash_score(cpu_scored : bool) -> void:
	pong_in_game_ui.flash_score(cpu_scored)
