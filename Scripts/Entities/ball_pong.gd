extends Ball

class_name BallPong

signal pong_rally_hit

@export var player_ref : Player
@export var enemy_ref : CPU

var predicted_x_position : float
var _last_collider_id : int = 0

func _ready() -> void:
	super._ready()
	original_position = global_position
	if player_ref == null:
		player_ref = get_tree().get_first_node_in_group(GameConfig.GROUP_PLAYER) as Player
	if enemy_ref == null:
		enemy_ref = get_tree().get_first_node_in_group(GameConfig.GROUP_CPU) as CPU

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if collision_info == null:
		_last_collider_id = 0

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
	player = player_ref if player_ref != null else get_tree().get_first_node_in_group(GameConfig.GROUP_PLAYER) as Player
	predicted_x_position = global_position.x

func _on_collided() -> void:
	_pong_mode()

func _pong_mode() -> void:
	if collision_info:
		var collider : Node2D = collision_info.get_collider() as Node2D
		if collider == null:
			return
		if collider.get_instance_id() != _last_collider_id:
			_last_collider_id = collider.get_instance_id()
			_move()
			if collider is Player:
				_predict_ball_pos()
				_trigger_cpu_reaction()
			if collider is Player or collider is CPU:
				pong_rally_hit.emit()
	else:
		_last_collider_id = 0

func _trigger_cpu_reaction() -> void:
	var enemy : CPU = enemy_ref if enemy_ref != null else get_tree().get_first_node_in_group(GameConfig.GROUP_CPU) as CPU
	if enemy:
		enemy.trigger_reaction_delay()

func _predict_ball_pos() -> void:
	if abs(direction.y) < 0.0001:
		return
	var predicted_x : float = global_position.x + (GameConfig.CPU_PADDLE_Y - global_position.y) / direction.y * direction.x
	predicted_x = pingpong(predicted_x, GameConfig.TABLE_WIDTH - GameConfig.BALL_DIAMETER)
	predicted_x_position = predicted_x
