extends LevelBB

class_name LevelBbModern

@export_group("Ball")

@onready var balls: BallsBb = $BallsBB
@onready var bb_mod_player: BbModPlayer = $BBModPlayer
@onready var ball_spawn_timer: Timer = $BallSpawnTimer
@onready var trajectory_line : Trajectory = bb_mod_player.trajectory
@onready var level_timer: Timer = $LevelTimer
@onready var bb_modern_in_game_ui: BBModInGameUi = $BBModernInGameUI
@onready var audio_manager : Audio = AudioManager

const INCREMENT : int = 1
const Min_Angle : float = 15
const Max_Angle : float = 165

var _level : int = 1
var level : int :
	get :
		return _level
	set(value):
		_level = value
		bb_modern_in_game_ui.level.text = "%2d" % [_level]
		_animate_level_label()
var num_of_balls : int = 1
var _level_started : bool = false
var level_started : bool :
	get:
		return _level_started
	set(value):
		_level_started = value
		if value == false:
			_next_level()
		else:
			_shoot()
var _level_transitioning : bool = false
var time : float = 0.0
var _last_displayed_second : int = -1

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
	if balls.is_empty() and not trajectory_line.visible and level_started:
		level_started = false

func _time(delta : float) -> void:
	time += delta
	var current_second : int = int(time) % 60
	if current_second != _last_displayed_second:
		_last_displayed_second = current_second
		var seconds : float = fmod(time, 60)
		var minutes : float = fmod(time, 3600) / 60
		bb_modern_in_game_ui.time.text = "%02d : %02d" % [minutes, seconds]

func _shoot() -> void:
	trajectory_line.hide()
	level_timer.start()
	balls._make_balls(num_of_balls,trajectory_line.global_position,trajectory_line.get_forward_direction())

func _limit_shooting_angle() -> void:
	var angle_to_mouse : float = PI + trajectory_line.get_forward_direction().angle()
	if angle_to_mouse > deg_to_rad(Min_Angle) and angle_to_mouse < deg_to_rad(Max_Angle) and not trajectory_line.visible:
		trajectory_line.show()
	elif (angle_to_mouse < deg_to_rad(Min_Angle) or angle_to_mouse > deg_to_rad(Max_Angle)) and trajectory_line.visible:
		trajectory_line.hide()

func _next_level() -> void:
	if _level_transitioning:
		return
	_level_transitioning = true
	balls.clean_up()
	balls.speed_multiplier = 1.0
	if bb_modern_in_game_ui.retrieve_balls.visible:
		bb_modern_in_game_ui.retrieve_balls.hide()
		if bb_modern_in_game_ui._pulse_tween:
			bb_modern_in_game_ui._pulse_tween.kill()
			bb_modern_in_game_ui.retrieve_balls.scale = Vector2.ONE
	if level_timer.time_left:
		level_timer.stop()
	var tween : Tween = _move_old_blocks()
	if not block_y_pos_array.is_empty() and block_y_pos_array.back() >= 1800:
		bb_modern_in_game_ui._on_lose()
		global.bb_mod_dict.clear()
		global._save_game(global.bb_mod_sav_path, global.bb_mod_dict)
	level += INCREMENT
	num_of_balls += INCREMENT
	if level % 10 == 0:
		await tween.finished
		_save()
	_level_transitioning = false

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
	balls.set_speed_multiplier(1.25)
	bb_modern_in_game_ui.retrieve_balls.disabled = false
	bb_modern_in_game_ui.retrieve_balls.show()
	_pulse_retrieve_button()

func _animate_level_label() -> void:
	var label : Label = bb_modern_in_game_ui.level
	label.scale = Vector2(1.5, 1.5)
	label.modulate = Color(1, 0.8, 0.2)
	var tween : Tween = create_tween().set_parallel(true)
	tween.tween_property(label, "scale", Vector2.ONE, 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(label, "modulate", Color.WHITE, 0.3)

func _pulse_retrieve_button() -> void:
	var btn : Button = bb_modern_in_game_ui.retrieve_balls
	if bb_modern_in_game_ui._pulse_tween:
		bb_modern_in_game_ui._pulse_tween.kill()
	var tween : Tween = create_tween().set_loops()
	tween.tween_property(btn, "scale", Vector2(1.05, 1.05), 0.5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(btn, "scale", Vector2.ONE, 0.5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	bb_modern_in_game_ui._pulse_tween = tween
