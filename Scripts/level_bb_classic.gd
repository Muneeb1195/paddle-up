extends LevelBB

class_name LEVELBBCLASSIC

@onready var player : Player = $Player
@onready var trajectory_line : Trajectory = $Player/Trajectory
@onready var ball: Ball = $Ball
@onready var bb_classic_in_game_ui: BBClassicInGameUi = $BBClassicInGameUI

var level : int = 1:
	set(value):
		level = value
		bb_classic_in_game_ui.score.text = "%2d" % [level]
var level_started : bool = false:
	set(value):
		level_started = value
		if value == false:
			set_process(true)
		else:
			set_process(false)
var lives : int = 3:
	set(value):
		lives = value
		bb_classic_in_game_ui.lives.text = "%2d" % [lives]
		if lives <= 0:
			bb_classic_in_game_ui._on_lose()
			ball.queue_free()

func _ready() -> void:
	if global.bb_clas_dict:
		_load()
	else:
		super._ready()
		_save()
	trajectory_line.modulate = global._choose_color()

func _process(_delta: float) -> void:
	if not level_started:
		ball.position.x = player.position.x

func _input(event: InputEvent) -> void:
	if event is InputEventMouse:
		if event.is_action_released(&"HoldnShoot") and trajectory_line.visible:
			_shoot()
		elif event is InputEventMouseMotion and not level_started:
			_limit_shooting_angle()
			_stop_paddle_movement()

func _shoot() -> void:
	ball._set_direction_move()
	level_started = true
	trajectory_line.hide()
	player.set_physics_process(true)

func _limit_shooting_angle() -> void:
	var angle_to_mouse : float = get_global_mouse_position().angle_to_point(trajectory_line.global_position)
	var distance_to_mouse : float = get_global_mouse_position().distance_to(trajectory_line.global_position)
	if angle_to_mouse > deg_to_rad(15) and angle_to_mouse < deg_to_rad(165) and not trajectory_line.visible and distance_to_mouse > 150:
		trajectory_line.show()
	elif (angle_to_mouse < deg_to_rad(15) or angle_to_mouse > deg_to_rad(165)) and trajectory_line.visible or distance_to_mouse <= 150:
		trajectory_line.hide()

func _stop_paddle_movement() -> void:
	if trajectory_line.visible:
		player.set_physics_process(false)
	else:
		player.set_physics_process(true)

func _reset() -> void:
	if lives > 0:
		await get_tree().create_timer(1.0).timeout
		ball.set_process(true)
		level_started = false
		ball.show()

func _save() -> void:
	global.bb_clas_dict = {"bb_clas_stats" : _save_stats(), "bb_clas_bricks" : _save_bricks()}
	global._save_game(global.bb_clas_sav_path,global.bb_clas_dict)

func _load() -> void:
	_load_bricks(global.bb_clas_dict["bb_clas_bricks"])
	_load_stats()

func _save_stats() -> Dictionary:
	var stats_dict : Dictionary
	stats_dict = {
		"level" = level,
		"lives" = lives,
		"brick_hp" = block_hp,
		"paddle_pos_x" = player.position.x
	}
	return stats_dict

func _load_stats() -> void:
	var stats_dict : Dictionary = global.bb_clas_dict["bb_clas_stats"]
	level = stats_dict["level"]
	lives = stats_dict["lives"]
	block_hp = stats_dict["brick_hp"]
	player.position.x = stats_dict["paddle_pos_x"]

func _on_ball_bb_classic_next_level() -> void:
	level += 1
	_move_old_blocks()
	#_add_new_block_row()
	#_sort_blocks()
	if block_y_pos_array.back() >= 1800:
		bb_classic_in_game_ui._on_lose()
	if level % 10 == 0:
			lives += 1
			_save()

func _on_floor_body_entered(body: Node2D) -> void:
	if body is Ball:
		lives -= 1
		ball.hide()
		ball.set_process(false)
		ball.velocity = Vector2.ZERO
		ball.global_position = ball.orignal_position
		_reset()
