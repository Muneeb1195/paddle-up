extends Node2D

class_name BallsBB

@export var ball_bb_scene : PackedScene
@onready var timer: Timer = $"../BallSpawnTimer"
@onready var bb_mod_player: BBMODPLAYER = get_tree().get_first_node_in_group(&"BBModPlayer")
@onready var level : LEVELBBMODERN = get_tree().get_first_node_in_group(&"LevelBBModern")

var global : Globals = Global
@onready var audio_manager : Audio = AudioManager

enum BB_STATES {Move,Stop}

const MIN_BOUNDS : Vector2 = Vector2(0,150)
const MAX_BOUNDS : Vector2 = Vector2(1000,1950)
const speed : int = 900
const INITIAL_POOL : int = 512
const MAX_POOL : int = 10000

var ball_nodes : Array[CharacterBody2D] = []
var ball_states : Array[BB_STATES] = []
var ball_pool : Array[CharacterBody2D] = []
var _balls_to_spawn : int = 0
var _spawn_pos : Vector2 = Vector2.ZERO
var _spawn_dir : Vector2 = Vector2.ZERO
var _spawn_index : int = 0
var new_pad_x_pos : int
var get_pad_pos : bool = false
var got_pad_pos : bool = false
var move_paddle : bool = false
var _frame_counter : int = 0

func _ready() -> void:
	modulate = global._choose_color()
	for i : int in INITIAL_POOL:
		var b : CharacterBody2D = ball_bb_scene.instantiate()
		b.visible = false
		add_child(b)
		ball_pool.append(b)
	timer.timeout.connect(_on_spawn_timer_timeout)

func _physics_process(delta: float) -> void:
	_frame_counter += 1
	var i : int = ball_nodes.size() - 1
	while i >= 0:
		if ball_states[i] == BB_STATES.Move:
			var collision : KinematicCollision2D = ball_nodes[i].move_and_collide(ball_nodes[i].velocity * delta)
			if collision:
				var body : Node2D = collision.get_collider()
				if body.is_in_group(&"Brick"):
					level._reduce_block_hp(body)
					ball_nodes[i].velocity = ball_nodes[i].velocity.bounce(collision.get_normal())
				elif body is BBMODPLAYER:
					ball_nodes[i].velocity = ball_nodes[i].velocity.bounce(collision.get_normal())
					ball_states[i] = BB_STATES.Stop
					ball_nodes[i].collision_mask = 17
				else:
					ball_nodes[i].velocity = ball_nodes[i].velocity.bounce(collision.get_normal())
			var pos : Vector2 = ball_nodes[i].global_position
			if pos.x < MIN_BOUNDS.x:
				ball_nodes[i].global_position.x = MIN_BOUNDS.x
				ball_nodes[i].velocity.x = abs(ball_nodes[i].velocity.x)
			elif pos.x > MAX_BOUNDS.x:
				ball_nodes[i].global_position.x = MAX_BOUNDS.x
				ball_nodes[i].velocity.x = -abs(ball_nodes[i].velocity.x)
			if pos.y < MIN_BOUNDS.y:
				ball_nodes[i].global_position.y = MIN_BOUNDS.y
				ball_nodes[i].velocity.y = abs(ball_nodes[i].velocity.y)
			elif pos.y > MAX_BOUNDS.y:
				ball_nodes[i].global_position.y = MAX_BOUNDS.y
				ball_nodes[i].velocity.y = -abs(ball_nodes[i].velocity.y)
		elif ball_states[i] == BB_STATES.Stop:
			var dir : Vector2 = ball_nodes[i].position.direction_to(bb_mod_player.trajectory.global_position)
			ball_nodes[i].velocity = lerp(ball_nodes[i].velocity, dir * speed, clampf(5.0 * delta, 0.0, 1.0))
			var stop_col : KinematicCollision2D = ball_nodes[i].move_and_collide(ball_nodes[i].velocity * delta)
			if stop_col:
				ball_nodes[i].velocity = ball_nodes[i].velocity.bounce(stop_col.get_normal())
			if get_pad_pos:
				new_pad_x_pos = int(ball_nodes[i].global_position.x)
				get_pad_pos = false
				got_pad_pos = true
			if _frame_counter % 3 == 0 and ball_nodes[i].position.distance_to(bb_mod_player.trajectory.global_position) < 5:
				_return_to_pool(ball_nodes[i])
				var last : int = ball_nodes.size() - 1
				ball_nodes[i] = ball_nodes[last]
				ball_states[i] = ball_states[last]
				ball_nodes.pop_back()
				ball_states.pop_back()
				if i >= ball_nodes.size():
					break
				continue
		i -= 1
	if ball_nodes.is_empty() and _spawn_index < _balls_to_spawn:
		cancel_spawning()
	if move_paddle and got_pad_pos:
		bb_mod_player._move_paddle(new_pad_x_pos)
		move_paddle = false
		got_pad_pos = false

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
	var node : CharacterBody2D = _get_pooled_ball()
	if node == null:
		return
	node.position = _spawn_pos
	node.velocity = _spawn_dir * speed
	node.visible = true
	ball_nodes.append(node)
	ball_states.append(BB_STATES.Move)
	_spawn_index += 1
	if _spawn_index == _balls_to_spawn:
		move_paddle = true
	if _spawn_index < _balls_to_spawn:
		timer.start()

func _get_pooled_ball() -> CharacterBody2D:
	if ball_pool.is_empty():
		if ball_pool.size() + ball_nodes.size() >= MAX_POOL:
			return null
		var b : CharacterBody2D = ball_bb_scene.instantiate()
		b.visible = false
		add_child(b)
		return b
	return ball_pool.pop_back()

func retrieve_all_balls() -> void:
	for i : int in ball_states.size():
		ball_states[i] = BB_STATES.Stop
		ball_nodes[i].collision_mask = 17
		ball_nodes[i].velocity = ball_nodes[i].position.direction_to(bb_mod_player.trajectory.global_position) * speed

func _return_to_pool(b : CharacterBody2D) -> void:
	b.visible = false
	b.velocity = Vector2.ZERO
	b.position = Vector2(-1000, -1000)
	b.collision_mask = 145
	if ball_pool.size() + ball_nodes.size() < MAX_POOL:
		ball_pool.append(b)
	else:
		b.queue_free()

func cancel_spawning() -> void:
	_balls_to_spawn = 0
	_spawn_index = 0
	timer.stop()

func clean_up() -> void:
	cancel_spawning()
	for i : int in ball_nodes.size():
		_return_to_pool(ball_nodes[i])
	ball_nodes.clear()
	ball_states.clear()
