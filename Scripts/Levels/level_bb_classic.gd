extends LevelBb

class_name LevelBbClassic

@onready var player : Player = $Player
@onready var trajectory_line : Trajectory = $Player/Trajectory
@onready var ball: BallBbClassic = $Ball
@onready var bb_classic_in_game_ui: BBClassicInGameUi = $BBClassicInGameUI

var _level_transitioning : bool = false
var _level : int = 1
var level : int :
	get :
		return _level
	set(value):
		_level = value
		bb_classic_in_game_ui.score.text = "%2d" % [_level]
var _ball_launched : bool = false
var ball_launched : bool :
	get :
		return _ball_launched
	set(value):
		_ball_launched = value
		set_process(not value)
var _lives : int = 3
var lives : int :
	get :
		return _lives
	set(value):
		_lives = value
		bb_classic_in_game_ui.lives.text = "%2d" % [_lives]
		if _lives <= 0:
			bb_classic_in_game_ui._on_lose()
			ball.queue_free()

func _ready() -> void:
	ball.brick_hit.connect(_reduce_block_hp)
	if save_manager.bb_clas_dict:
		_load()
	else:
		super._ready()
		_save()
	trajectory_line.modulate = global._choose_color()

func _process(_delta: float) -> void:
	if not ball_launched and is_instance_valid(ball):
		ball.position.x = player.position.x

func _input(event: InputEvent) -> void:
	if event is InputEventMouse:
		if event.is_action_released(&"HoldnShoot") and trajectory_line.visible:
			_shoot()
		elif event is InputEventMouseMotion and not ball_launched:
			_limit_shooting_angle()

func _shoot() -> void:
	if not is_instance_valid(ball):
		return
	ball._set_direction_move(trajectory_line.get_shot_direction())
	ball_launched = true
	trajectory_line.hide()
	player.set_physics_process(true)
	player.set_process_input(true)

func _limit_shooting_angle() -> void:
	if trajectory_line.is_aim_valid() and not trajectory_line.visible:
		trajectory_line.show()
		player.set_physics_process(false)
		player.set_process_input(false)
	elif not trajectory_line.is_aim_valid() and trajectory_line.visible:
		trajectory_line.hide()
		player.set_physics_process(true)
		player.set_process_input(true)

func _reset() -> void:
	if lives > 0:
		await get_tree().create_timer(1.0).timeout
		if not is_instance_valid(ball):
			return
		ball.set_physics_process(true)
		ball_launched = false
		ball.show()

func _save() -> void:
	save_manager.bb_clas_dict = {"bb_clas_stats" : _save_stats(), "bb_clas_bricks" : _save_bricks()}
	save_manager.save_dict(SaveManager.GameKind.BB_CLASSIC, save_manager.bb_clas_dict)

func _load() -> void:
	_load_bricks(save_manager.bb_clas_dict["bb_clas_bricks"])
	_load_stats()

func _save_stats() -> Dictionary:
	var stats_dict : Dictionary
	stats_dict = {
		"level" : level,
		"lives" : lives,
		"brick_hp" : block_hp,
		"paddle_pos_x" : player.position.x
	}
	return stats_dict

func _load_stats() -> void:
	var stats_dict : Dictionary = save_manager.bb_clas_dict["bb_clas_stats"]
	level = stats_dict["level"]
	lives = stats_dict["lives"]
	block_hp = stats_dict["brick_hp"]
	player.position.x = stats_dict["paddle_pos_x"]

func _on_ball_bb_classic_next_level() -> void:
	if _level_transitioning:
		return
	_level_transitioning = true
	level += GameConfig.SCORE_INCREMENT
	if _lowest_brick_y() >= GameConfig.LOSE_ROW_Y:
		_level_transitioning = false
		bb_classic_in_game_ui._on_lose()
		return
	_move_old_blocks()
	await get_tree().create_timer(0.2).timeout
	_snap_bricks_to_grid()
	if level % 10 == 0:
			lives += 1
			_save()
	_level_transitioning = false

func _on_floor_body_entered(body: Node2D) -> void:
	if body is Ball:
		lives -= 1
		if not is_instance_valid(ball):
			return
		ball.hide()
		ball.set_physics_process(false)
		ball.velocity = Vector2.ZERO
		ball.global_position = ball.original_position
		_reset()
