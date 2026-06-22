extends Node2D

class_name BallsBb

@onready var timer: Timer = $"../BallSpawnTimer"
@onready var bb_mod_player: BbModPlayer = get_tree().get_first_node_in_group(&"BBModPlayer")
@onready var level : LevelBbModern = get_tree().get_first_node_in_group(&"LevelBBModern")

var global : Globals = Global
@onready var audio_manager : Audio = AudioManager

enum BB_STATES {Move,Stop}

const MIN_BOUNDS : Vector2 = Vector2(0,150)
const MAX_BOUNDS : Vector2 = Vector2(1000,1950)
const MAX_POOL : int = 10000

var _base_speed : int = 900
var speed_multiplier : float = 1.0

const MASK_ALL : int = 145
const MASK_WALLS_BLOCK : int = 17

var ball_positions : Array[Vector2] = []
var ball_velocities : Array[Vector2] = []
var ball_masks : Array[int] = []
var ball_states : Array[BB_STATES] = []
var _active_count : int = 0
var _probe : CharacterBody2D
var _multimesh : MultiMesh
var _ball_multi_mesh_node : MultiMeshInstance2D

var _balls_to_spawn : int = 0
var _spawn_pos : Vector2 = Vector2.ZERO
var _spawn_dir : Vector2 = Vector2.ZERO
var _spawn_index : int = 0

func _current_speed() -> int:
	return int(_base_speed * speed_multiplier)

func set_speed_multiplier(value: float) -> void:
	var ratio : float = value / speed_multiplier
	speed_multiplier = value
	for i : int in _active_count:
		if ball_states[i] == BB_STATES.Move:
			ball_velocities[i] *= ratio

var new_pad_x_pos : int
var get_pad_pos : bool = false
var got_pad_pos : bool = false
var move_paddle : bool = false
var _frame_counter : int = 0

func _ready() -> void:
	modulate = global._choose_color()
	_probe = $Probe
	_ball_multi_mesh_node = $BallMultiMesh
	_setup_multimesh()
	timer.timeout.connect(_on_spawn_timer_timeout)

func _setup_multimesh() -> void:
	var mm : MultiMesh = MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_2D
	var quad : QuadMesh = QuadMesh.new()
	quad.size = Vector2(20, 20)
	quad.surface_set_material(0, null)
	mm.mesh = quad
	mm.instance_count = MAX_POOL
	mm.visible_instance_count = 0
	_ball_multi_mesh_node.multimesh = mm
	_ball_multi_mesh_node.texture = preload("res://Assets/Ball/ball.png")
	_multimesh = mm

func _physics_process(delta: float) -> void:
	_frame_counter += 1
	var i : int = _active_count - 1
	while i >= 0:
		if ball_states[i] == BB_STATES.Move:
			_probe.global_position = ball_positions[i]
			_probe.collision_mask = ball_masks[i]
			var remaining : Vector2 = ball_velocities[i] * delta
			var hits : int = 0
			while hits < 3:
				var collision : KinematicCollision2D = _probe.move_and_collide(remaining)
				if not collision:
					break
				hits += 1
				Input.vibrate_handheld(5, 0.1)
				var body : Node2D = collision.get_collider()
				if body is BbModPlayer:
					ball_states[i] = BB_STATES.Stop
					ball_masks[i] = 0
					break
				if body.is_in_group(&"Brick"):
					level._reduce_block_hp(body)
				ball_velocities[i] = ball_velocities[i].bounce(collision.get_normal())
				var traveled : float = collision.get_travel().length()
				if traveled <= 0.0:
					break
				remaining = remaining.bounce(collision.get_normal())
				remaining = remaining.normalized() * maxf(remaining.length() - traveled, 0.0)
				if remaining.length() < 1.0:
					break
			ball_positions[i] = _probe.global_position
			_clamp_bounds(i)
		elif ball_states[i] == BB_STATES.Stop:
			var dir : Vector2 = ball_positions[i].direction_to(bb_mod_player.trajectory.global_position)
			ball_velocities[i] = lerp(ball_velocities[i], dir * _current_speed(), clampf(5.0 * delta, 0.0, 1.0))
			_probe.global_position = ball_positions[i]
			_probe.collision_mask = ball_masks[i]
			var remaining : Vector2 = ball_velocities[i] * delta
			var hits : int = 0
			while hits < 3:
				var stop_col : KinematicCollision2D = _probe.move_and_collide(remaining)
				if not stop_col:
					break
				hits += 1
				ball_velocities[i] = ball_velocities[i].bounce(stop_col.get_normal())
				var traveled : float = stop_col.get_travel().length()
				if traveled <= 0.0:
					break
				remaining = remaining.bounce(stop_col.get_normal())
				remaining = remaining.normalized() * maxf(remaining.length() - traveled, 0.0)
				if remaining.length() < 1.0:
					break
			ball_positions[i] = _probe.global_position
			if get_pad_pos:
				new_pad_x_pos = int(ball_positions[i].x)
				get_pad_pos = false
				got_pad_pos = true
			if ball_positions[i].distance_to(bb_mod_player.trajectory.global_position) < 20:
				_return_to_pool(i)
			else:
				_clamp_bounds(i)
		i -= 1
	_update_multimesh()
	if move_paddle and got_pad_pos:
		bb_mod_player._move_paddle(new_pad_x_pos)
		move_paddle = false
		got_pad_pos = false

func _clamp_bounds(idx: int) -> void:
	if ball_positions[idx].x < MIN_BOUNDS.x:
		ball_positions[idx].x = MIN_BOUNDS.x
		ball_velocities[idx].x = abs(ball_velocities[idx].x)
	elif ball_positions[idx].x > MAX_BOUNDS.x:
		ball_positions[idx].x = MAX_BOUNDS.x
		ball_velocities[idx].x = -abs(ball_velocities[idx].x)
	if ball_positions[idx].y < MIN_BOUNDS.y:
		ball_positions[idx].y = MIN_BOUNDS.y
		ball_velocities[idx].y = abs(ball_velocities[idx].y)
	elif ball_positions[idx].y > MAX_BOUNDS.y:
		ball_positions[idx].y = MAX_BOUNDS.y
		ball_velocities[idx].y = -abs(ball_velocities[idx].y)

func _update_multimesh() -> void:
	for i : int in _active_count:
		var xf : Transform2D = Transform2D(0, ball_positions[i])
		_multimesh.set_instance_transform_2d(i, xf)
	_multimesh.visible_instance_count = _active_count

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
	var idx : int = _get_pooled_ball()
	if idx == -1:
		return
	ball_positions[idx] = _spawn_pos
	ball_velocities[idx] = _spawn_dir * _current_speed()
	ball_masks[idx] = MASK_ALL
	ball_states[idx] = BB_STATES.Move
	_active_count += 1
	_spawn_index += 1
	if _spawn_index == _balls_to_spawn:
		move_paddle = true
	if _spawn_index < _balls_to_spawn:
		timer.start()

func _get_pooled_ball() -> int:
	if _active_count >= MAX_POOL:
		return -1
	if _active_count >= ball_positions.size():
		ball_positions.append(Vector2.ZERO)
		ball_velocities.append(Vector2.ZERO)
		ball_masks.append(MASK_ALL)
		ball_states.append(BB_STATES.Move)
	return _active_count

func retrieve_all_balls() -> void:
	for i : int in _active_count:
		ball_masks[i] = 0
		ball_states[i] = BB_STATES.Stop
		ball_velocities[i] = ball_positions[i].direction_to(bb_mod_player.trajectory.global_position) * _current_speed()

func _return_to_pool(idx: int) -> void:
	ball_positions[idx] = Vector2(-1000, -1000)
	ball_velocities[idx] = Vector2.ZERO
	_active_count -= 1
	if idx < _active_count:
		ball_positions[idx] = ball_positions[_active_count]
		ball_velocities[idx] = ball_velocities[_active_count]
		ball_masks[idx] = ball_masks[_active_count]
		ball_states[idx] = ball_states[_active_count]

func is_empty() -> bool:
	return _active_count == 0

func cancel_spawning() -> void:
	_balls_to_spawn = 0
	_spawn_index = 0
	timer.stop()

func clean_up() -> void:
	cancel_spawning()
	for i : int in range(_active_count - 1, -1, -1):
		_return_to_pool(i)
