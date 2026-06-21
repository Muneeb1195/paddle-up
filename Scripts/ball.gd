extends Entity

class_name Ball

signal bb_classic_next_level
signal pong_rally_hit

@export_enum("Pong","Brick Breaker Classic") var Game_Mode : String

var original_position : Vector2 = Vector2.ZERO
var audio_manager : Audio = AudioManager
var player : Player
var level : LEVELBBCLASSIC

func _ready() -> void:
	super._ready()
	randomize()
	match Game_Mode:
		"Pong":
			original_position = global_position
		"Brick Breaker Classic":
			player = get_tree().get_first_node_in_group("Player")
			original_position.y = global_position.y

func _process(_delta: float) -> void:
	match Game_Mode:
		"Pong":
			_pong_mode()
		"Brick Breaker Classic":
			level = get_tree().get_first_node_in_group(&"LevelBBClassic")
			_bb_classic_mode()

func _physics_process(delta: float) -> void:
	collision_info = move_and_collide(velocity * delta)
	if collision_info:
		Input.vibrate_handheld(5,0.3)

func _move() -> void:
	direction = (direction.bounce(collision_info.get_normal())).normalized()
	velocity = direction * speed

# BB Classic Code

var _num_of_coll_player : int = 0
var num_of_coll_player : int :
	get :
		return _num_of_coll_player
	set(value):
		_num_of_coll_player = value
		if _num_of_coll_player % 10 == 0:
			bb_classic_next_level.emit()

func  _set_direction_move() -> void:
	direction = position.direction_to(get_global_mouse_position())
	velocity = direction * speed

func _bb_classic_mode() -> void:
	original_position.x = player.position.x
	if collision_info:
		_move()
		_reduce_brick_hp()
		_check_hit_paddle()

func _check_hit_paddle() -> void:
	if collision_info.get_collider() is Player:
		num_of_coll_player += 1

func _reduce_brick_hp() -> void:
	if collision_info.get_collider() is StaticBody2D:
		var body : StaticBody2D = collision_info.get_collider()
		if body.is_in_group(&"Brick"):
			level._reduce_block_hp(body)

# BB Classic Code


# Pong Code

const BALL_DIAMETER : int = 20
const CPU_PADDLE_Y_POS : int = 260
const TABLE_WIDTH : int = 960 - BALL_DIAMETER

var predicted_x_position : float

func _pong_start(serve_up : bool = false) -> void:
	var spread : float = deg_to_rad(45.0)
	var angle : float = randf_range(-spread, spread)
	direction = Vector2(sin(angle), cos(angle)).normalized()
	if serve_up:
		direction.y = -direction.y
	if abs(direction.y) < 0.35:
		direction.y = sign(direction.y) * 0.35
		direction.x = sign(direction.x) * sqrt(maxf(0.0, 1.0 - direction.y * direction.y))
		direction = direction.normalized()
	velocity = direction * speed
	player = get_tree().get_first_node_in_group("Player")

func _pong_mode() -> void:
	if collision_info:
		_move()
		if collision_info.get_collider() is Player:
			_predict_ball_pos()
		if collision_info.get_collider() is Player or collision_info.get_collider() is CPU:
			pong_rally_hit.emit()

func _predict_ball_pos() -> void:
	if abs(direction.y) < 0.0001:
		return
	var predicted_x : float = global_position.x + (CPU_PADDLE_Y_POS - global_position.y) / direction.y * direction.x
	predicted_x = pingpong(predicted_x, TABLE_WIDTH)
	predicted_x_position = predicted_x

# Pong Code
