extends Node2D

class_name BallsBB

@export var ball_bb_scene : PackedScene
@onready var timer: Timer = $"../BallSpawnTimer"
@onready var bb_mod_player: BBMODPLAYER = get_tree().get_first_node_in_group(&"BBModPlayer")
@onready var level : LEVELBBMODERN = get_tree().get_first_node_in_group(&"LevelBBModern")

var global : Globals = Global
@onready var audio_manager : Audio = AudioManager

enum BB_STATES {Move,Stop}

const MOVE_BACK_DIST : int = 40
const MIN_BOUNDS : Vector2 = Vector2(0,150)
const MAX_BOUNDS : Vector2 = Vector2(1000,1950)
const speed : int = 900
const POOL_SIZE : int = 200

var balls : Array = []
var balls_to_remove : Array = []
var ball_pool : Array[RigidBody2D] = []
var _balls_to_spawn : int = 0
var _spawn_pos : Vector2 = Vector2.ZERO
var _spawn_dir : Vector2 = Vector2.ZERO
var _spawn_index : int = 0
var new_pad_x_pos : int
var get_pad_pos : bool = false
var got_pad_pos : bool = false
var move_paddle : bool = false

var _frame_counter : int = 0

class ball:
	var ball_bb : RigidBody2D
	var state : BB_STATES = BB_STATES.Move
	var collision_callable : Callable

func _ready() -> void:
	modulate = global._choose_color()
	for i : int in POOL_SIZE:
		var b : RigidBody2D = ball_bb_scene.instantiate()
		b.visible = false
		b.set_physics_process(false)
		b.set_process(false)
		add_child(b)
		ball_pool.append(b)
	timer.timeout.connect(_on_spawn_timer_timeout)

func _process(_delta: float) -> void:
	_frame_counter += 1
	if _frame_counter % 3 == 0:
		for i : ball in balls:
			if i.state == BB_STATES.Move:
				var pos : Vector2 = i.ball_bb.global_position
				if pos.x < MIN_BOUNDS.x:
					i.ball_bb.global_position.x += MOVE_BACK_DIST
				elif pos.x > MAX_BOUNDS.x:
					i.ball_bb.global_position.x -= MOVE_BACK_DIST
				elif pos.y < MIN_BOUNDS.y:
					i.ball_bb.global_position.y += MOVE_BACK_DIST
				elif pos.y > MAX_BOUNDS.y:
					i.ball_bb.global_position.y -= MOVE_BACK_DIST
	if move_paddle and got_pad_pos:
		bb_mod_player._move_paddle(new_pad_x_pos)
		move_paddle = false
		got_pad_pos = false

func _physics_process(delta: float) -> void:
	for i : ball in balls:
		if i.state == BB_STATES.Stop:
				var dir : Vector2 = i.ball_bb.position.direction_to(bb_mod_player.trajectory.global_position)
				i.ball_bb.linear_velocity = lerp(i.ball_bb.linear_velocity, dir * speed, clampf(15.0 * delta, 0.0, 1.0))
				if get_pad_pos:
					new_pad_x_pos = int(i.ball_bb.global_position.x)
					get_pad_pos = false
					got_pad_pos = true
				if i.ball_bb.position.distance_to(bb_mod_player.trajectory.global_position) < 5:
					_return_to_pool(i.ball_bb, i)
					balls_to_remove.append(i)
					#i.unreference()
					#balls.erase(i)
	for b : ball in balls_to_remove:
		balls.erase(b)
	balls_to_remove.clear()
	if balls.is_empty() and _spawn_index < _balls_to_spawn:
		cancel_spawning()

func _on_ball_collision(body : Node2D, ball_obj : ball) -> void:
	if ball_obj.state != BB_STATES.Move:
		return
	Input.vibrate_handheld(5, 0.3)
	if body.is_in_group(&"Brick"):
		level._reduce_block_hp(body)
	elif body is BBMODPLAYER:
		ball_obj.state = BB_STATES.Stop

func _make_balls(num_of_balls: int, pos : Vector2, dir : Vector2) -> void:
	audio_manager.ball_spawn.play()
	_balls_to_spawn = num_of_balls
	_spawn_pos = pos
	_spawn_dir = dir
	_spawn_index = 0
	get_pad_pos = true
	_spawn_next_ball()

func _on_spawn_timer_timeout() -> void:
	_spawn_next_ball()

func _spawn_next_ball() -> void:
	if _spawn_index >= _balls_to_spawn:
		return
	var new_ball : ball = ball.new()
	new_ball.ball_bb = _get_pooled_ball()
	new_ball.ball_bb.position = _spawn_pos
	new_ball.ball_bb.linear_velocity = _spawn_dir * speed
	new_ball.ball_bb.visible = true
	new_ball.ball_bb.set_physics_process(true)
	new_ball.ball_bb.set_process(true)
	new_ball.collision_callable = _on_ball_collision.bind(new_ball)
	new_ball.ball_bb.body_entered.connect(new_ball.collision_callable)
	balls.push_back(new_ball)
	_spawn_index += 1
	if _spawn_index == _balls_to_spawn:
		move_paddle = true
	if _spawn_index < _balls_to_spawn:
		timer.start()

func retrieve_all_balls() -> void:
	for ball_obj : ball in balls:
		ball_obj.state = BB_STATES.Stop

func _get_pooled_ball() -> RigidBody2D:
	if ball_pool.is_empty():
		var b : RigidBody2D = ball_bb_scene.instantiate()
		add_child(b)
		return b
	return ball_pool.pop_back()

func _return_to_pool(b : RigidBody2D, ball_obj : ball) -> void:
	if b.body_entered.is_connected(ball_obj.collision_callable):
		b.body_entered.disconnect(ball_obj.collision_callable)
	b.visible = false
	b.set_physics_process(false)
	b.set_process(false)
	b.linear_velocity = Vector2.ZERO
	b.position = Vector2(-1000, -1000)
	ball_pool.append(b)

func cancel_spawning() -> void:
	_balls_to_spawn = 0
	_spawn_index = 0
	timer.stop()

func clean_up() -> void:
	cancel_spawning()
	# Return any leaked balls to pool immediately
	for ball_obj : ball in balls:
		_return_to_pool(ball_obj.ball_bb, ball_obj)
		balls_to_remove.append(ball_obj)
	for b : ball in balls_to_remove:
		balls.erase(b)
	balls_to_remove.clear()
