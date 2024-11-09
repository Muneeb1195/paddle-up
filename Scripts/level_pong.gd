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
var cpu_points : int = 0:
	set(value):
		cpu_points = value
		pong_in_game_ui.cpu_points.text = "Cpu Points: " + "%2d" % [cpu_points]
		if cpu_points >= max_points:
			pong_in_game_ui._display_lose_screen()
var player_points : int = 0:
	set(value):
		player_points = value
		pong_in_game_ui.player_points.text = "Player Points: " + "%2d" % [player_points]
		if player_points >= max_points:
			pong_in_game_ui._display_win_screen()
var ball_starting_speed : int

const INCREMENT : int = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pong_table.wall.modulate = global._choose_color()
	pong_in_game_ui.difficulty_menu.easy.pressed.connect(_on_easy_pressed)
	pong_in_game_ui.difficulty_menu.medium.pressed.connect(_on_medium_pressed)
	pong_in_game_ui.difficulty_menu.hard.pressed.connect(_on_hard_pressed)
	

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
			enemy.acceleration = 1
			ball.speed_mod = 40
			enemy.minimum_detect_dist = 600
		DIFFICULTY.Medium:
			ball_starting_speed = 500
			ball.speed_mod = 45
			enemy.minimum_detect_dist = 700
			enemy.acceleration = 2
		DIFFICULTY.Hard:
			ball_starting_speed = 600
			ball.speed_mod = 50
			enemy.minimum_detect_dist = 850
			enemy.acceleration = 3
	_start_pong()

func _start_pong() -> void:
	await get_tree().create_timer(1.0).timeout
	ball.show()
	ball.set_process(true)
	ball.speed = ball_starting_speed
	await get_tree().create_timer(4.0).timeout
	ball._pong_start()

func _move_ball_back() -> void:
	ball.hide()
	ball.set_process(false)
	ball.velocity = Vector2.ZERO
	ball.global_position = ball.orignal_position
	_start_pong()

func _increase_player_point() -> void:
	player_points += INCREMENT
	_move_ball_back()

func _increase_cpu_point() -> void:
	cpu_points += INCREMENT
	_move_ball_back()
