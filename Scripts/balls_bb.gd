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

var balls : Array
var new_pad_x_pos : int
var get_pad_pos : bool = false
var got_pad_pos : bool = false
var move_paddle : bool = false

class ball:
	var ball_bb : RigidBody2D
	var state : BB_STATES = BB_STATES.Move

func _ready() -> void:
	modulate = global._choose_color()

func _process(_delta: float) -> void:
	for i : ball in balls:
		match i.state:
			BB_STATES.Move:
				if i.ball_bb.position.x < MIN_BOUNDS.x:
					i.ball_bb.global_position.x += MOVE_BACK_DIST
				elif i.ball_bb.position.x > MAX_BOUNDS.x:
					i.ball_bb.global_position.x -= MOVE_BACK_DIST
				elif i.ball_bb.position.y < MIN_BOUNDS.y:
					i.ball_bb.global_position.y += MOVE_BACK_DIST
				elif i.ball_bb.position.y > MAX_BOUNDS.y:
					i.ball_bb.global_position.y -= MOVE_BACK_DIST
	if move_paddle and got_pad_pos:
		bb_mod_player._move_paddle(new_pad_x_pos)
		move_paddle = false
		got_pad_pos = false

func _physics_process(delta: float) -> void:
	for i : ball in balls:
		match i.state:
			BB_STATES.Move:
				if not i.ball_bb.get_colliding_bodies().is_empty():
					Input.vibrate_handheld(5,0.3)
					for body : Node2D in i.ball_bb.get_colliding_bodies():
						if body.is_in_group(&"Brick"):
							level._reduce_block_hp(body)
						elif body is BBMODPLAYER:
							i.state = BB_STATES.Stop
			BB_STATES.Stop:
				var dir : Vector2 = i.ball_bb.position.direction_to(bb_mod_player.trajectory.global_position)
				i.ball_bb.linear_velocity = lerp(i.ball_bb.linear_velocity,dir * speed,5 * delta)
				if get_pad_pos:
					new_pad_x_pos = int(i.ball_bb.global_position.x)
					get_pad_pos = false
					got_pad_pos = true
				if i.ball_bb.position.distance_to(bb_mod_player.trajectory.global_position) < 5:
					i.ball_bb.queue_free()
					i.unreference()
					balls.erase(i)

func _make_balls(num_of_balls: int, pos : Vector2, dir : Vector2) -> void:
	audio_manager.ball_spawn.play()
	get_pad_pos = true
	for i : int in num_of_balls:
		timer.start()
		var new_ball : ball = ball.new()
		new_ball.ball_bb = ball_bb_scene.instantiate()
		new_ball.ball_bb.position = pos
		new_ball.ball_bb.linear_velocity = (dir * speed)
		balls.push_back(new_ball)
		if i == num_of_balls - 1:
			move_paddle = true
		add_child(new_ball.ball_bb)
		await timer.timeout
