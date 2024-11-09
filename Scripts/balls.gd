extends Node2D

class_name BallSpawner

var got_new_paddle_pos : bool = false
var new_paddle_x_pos : float

@onready var bb_modern_in_game_ui: BBModInGameUi = $"../BBModernInGameUI"
@onready var ball_spawn_timer: Timer = $"../Timer" #$"../BallSpawnTimer"
@onready var bb_mod_player : BBMODPLAYER = get_tree().get_first_node_in_group(&"BBModPlayer")
@onready var level : LEVELBBMODERN = get_tree().get_first_node_in_group(&"LevelBBModern")
@onready var audio_manager : Audio = AudioManager
@onready var global : Globals = Global

enum BB_STATES {Move,Stop}

var img : CompressedTexture2D = preload("res://Assets/Ball/ball.png")
var balls : Array
var speed : int = 1000
var start_pos : Vector2
var offset : Vector2 = Vector2(-10,-10)
const radius : int = 10
var shape_rid : RID
var space_state : PhysicsDirectSpaceState2D
var query : PhysicsShapeQueryParameters2D 
var disable_pause : bool = false
	#set(value):
		#disable_pause = value
		#match value:
			#true:
				#bb_modern_in_game_ui.pause.disabled = true
			#false:
				#bb_modern_in_game_ui.pause.disabled = false

class ball:
	var state : BB_STATES = BB_STATES.Move
	var pos : Vector2
	var direction : Vector2
	#var individual_query : PhysicsShapeQueryParameters2D
	#var body : RID = RID()

func _ready() -> void:
	modulate = global._choose_color()
	space_state = get_world_2d().direct_space_state
	shape_rid = PhysicsServer2D.circle_shape_create()
	PhysicsServer2D.shape_set_data(shape_rid,radius)
	query = PhysicsShapeQueryParameters2D.new()
	query.shape_rid = shape_rid
	query.margin = 1
	query.collision_mask = 145

func _process(_delta: float) -> void:
	queue_redraw()
	#for i : ball in balls:
		#if i.pos.x > 550 or i.pos.x < -550 or i.pos.y > 300 or i.pos.y < -1800:
			##PhysicsServer2D.free_rid(i.body)
			#balls.erase(i)

func _physics_process(delta: float) -> void:
	for i : ball in balls:
		match i.state:
			BB_STATES.Move:
				i.pos += i.direction * speed * delta
				var pointA : Vector2 = i.pos - global_position - offset
				#i.individual_query.transform = Transform2D(0.0,pointA)
				#var result : Dictionary = space_state.get_rest_info(i.individual_query)
				#var info : Array[Dictionary] = space_state.intersect_shape(i.individual_query,1)
				var shape : Dictionary = _shape_query(pointA)
				if not shape.is_empty():
					audio_manager.bounce.play()
					i.direction = i.direction.bounce(shape.result.normal)
					if shape.info.collider is Brick:
						shape.info.collider.call("_reduce_hp")
					elif shape.info.collider is BBMODPLAYER:
						i.state = BB_STATES.Stop
			BB_STATES.Stop:
				i.pos = lerp(i.pos,bb_mod_player.trajectory.global_position + offset,5 * delta)
				if i.pos.distance_to(bb_mod_player.trajectory.global_position + offset) < 5:
					balls.erase(i)
				if not got_new_paddle_pos:
					got_new_paddle_pos = true
					new_paddle_x_pos = i.pos.x

func _make_balls(num_of_balls : int, dir : Vector2) -> void:
	print(num_of_balls)
	got_new_paddle_pos = false
	disable_pause = true
	for i : int in num_of_balls:
		ball_spawn_timer.start()
		audio_manager.ball_spawn.play()
		var new_ball : ball = ball.new()
		new_ball.pos = start_pos + offset
		new_ball.direction = dir
		balls.push_back(new_ball)
		if i == num_of_balls - 1:
			bb_mod_player._move_paddle(new_paddle_x_pos)
			disable_pause = false
		await ball_spawn_timer.timeout

func _shape_query(pointA : Vector2) -> Dictionary:
	query.transform = Transform2D(0.0, pointA)
	var result : Dictionary = space_state.get_rest_info(query)
	var info : Array[Dictionary] = space_state.intersect_shape(query,1)
	if not result.is_empty():
		return {"result" : result, "info" : info.back()}
	return {}

func _draw() -> void:
	for i: ball in balls:
		draw_texture(img,i.pos)

func _exit_tree() -> void:
	for i: ball in balls:
		PhysicsServer2D.free_rid(i.body)
	PhysicsServer2D.free_rid(shape_rid)
	balls.clear()
