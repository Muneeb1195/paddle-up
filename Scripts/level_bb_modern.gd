extends LevelBB

class_name LEVELBBMODERN

@export_group("Ball")

@onready var balls: BallsBB = $BallsBB
@onready var bb_mod_player: BBMODPLAYER = $BBModPlayer
@onready var ball_spawn_timer: Timer = $BallSpawnTimer
@onready var trajectory_line : Trajectory = bb_mod_player.trajectory
@onready var level_timer: Timer = $LevelTimer
@onready var bb_modern_in_game_ui: BBModInGameUi = $BBModernInGameUI
@onready var audio_manager : Audio = AudioManager

const  INCREAMENT : int = 1
const Min_Angle : float = 15
const Max_Angle : float = 165

var level : int = 1:
	set(value):
		level = value
		bb_modern_in_game_ui.level.text = "%2d" % [level]
var num_of_balls : int = 1
var level_started : bool = false:
	set(value):
		level_started = value
		if value == false:
			_next_level()
		else:
			_shoot()
var time : float = 0.0

func _ready() -> void:
	if global.bb_mod_dict.has("bb_mod_stats") and global.bb_mod_dict.has("bb_mod_bricks"):
		_load()
	else:
		super._ready()
		_save()

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.is_released() and trajectory_line.visible and not level_started:
			level_started = true
	if event is InputEventScreenDrag and not level_started:
		_limit_shooting_angle()

func _process(delta: float) -> void:
	_time(delta)
	if balls.balls.is_empty() and not trajectory_line.visible and level_started:
		level_started = false

func _time(delta : float) -> void:
	time += delta
	var seconds : float = fmod(time, 60)
	var minutes : float = fmod(time, 3600) / 60
	var str_elapsed : String = "%02d : %02d" % [minutes, seconds]
	bb_modern_in_game_ui.time.text = str_elapsed

func _shoot() -> void:
	trajectory_line.hide()
	level_timer.start()
	balls._make_balls(num_of_balls,trajectory_line.global_position,trajectory_line.get_forward_direction())

func _limit_shooting_angle() -> void:
	var angle_to_mouse : float = PI + trajectory_line.get_forward_direction().angle()
	if angle_to_mouse > deg_to_rad(Min_Angle) and angle_to_mouse < deg_to_rad(Max_Angle) and not trajectory_line.visible:
		trajectory_line.show()
	elif angle_to_mouse < deg_to_rad(Min_Angle) or angle_to_mouse > deg_to_rad(Max_Angle) and trajectory_line.visible:
		trajectory_line.hide()

func _next_level() -> void:
	if Engine.get_time_scale() > 1.0:
		Engine.set_time_scale(1.0)
		bb_modern_in_game_ui.retrive_balls.hide()
	if level_timer.time_left:
		level_timer.stop()
	_move_old_blocks()
	if block_y_pos_array.back() >= 1900:
		bb_modern_in_game_ui._on_lose()
		global.bb_mod_dict.clear()
	level += INCREAMENT
	num_of_balls += INCREAMENT
	if level % 10 == 0:
		_save()

func _save() -> void:
	global.bb_mod_dict = {"bb_mod_stats": _save_stats(), "bb_mod_bricks" : _save_bricks()}
	global._save_game(global.bb_mod_sav_path,global.bb_mod_dict)

func _load() -> void:
	_load_bricks(global.bb_mod_dict["bb_mod_bricks"])
	_load_stats()

func _save_stats() -> Dictionary:
	var stats_dict : Dictionary
	stats_dict = {
		"level" : level,
		"num_of_balls" : num_of_balls,
		"brick_hp": block_hp,
		"paddle_pos_x" : bb_mod_player.paddle.global_position.x
	}
	return stats_dict

func _load_stats() -> void:
	var stats_dict : Dictionary = global.bb_mod_dict["bb_mod_stats"]
	level = stats_dict["level"]
	num_of_balls = stats_dict["num_of_balls"]
	block_hp = stats_dict["brick_hp"]
	bb_mod_player._move_paddle(stats_dict["paddle_pos_x"])


func _on_level_timer_timeout() -> void:
	Engine.set_time_scale(1.25)
	bb_modern_in_game_ui.retrive_balls.disabled = false
	bb_modern_in_game_ui.retrive_balls.show()
