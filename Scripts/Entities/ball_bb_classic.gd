extends Ball

class_name BallBbClassic

signal bb_classic_next_level

var level : LevelBbClassic
var _last_collider_id : int = 0

# Increments on every paddle hit; triggers level-up every 10 hits.
var _num_of_coll_player : int = 0
var num_of_coll_player : int :
	set(value):
		_num_of_coll_player = value
		if _num_of_coll_player % 10 == 0:
			bb_classic_next_level.emit()

func _ready() -> void:
	super._ready()
	player = get_tree().get_first_node_in_group(GameConfig.GROUP_PLAYER)
	level = get_tree().get_first_node_in_group(GameConfig.GROUP_LEVEL_BB_CLASSIC)
	original_position.y = global_position.y

func _process(_delta: float) -> void:
	_bb_classic_mode()

func _set_direction_move(aim_direction : Vector2) -> void:
	direction = aim_direction.normalized()
	velocity = direction * speed

func _bb_classic_mode() -> void:
	original_position.x = player.position.x
	if collision_info:
		var collider : Node2D = collision_info.get_collider() as Node2D
		if collider == null:
			return
		if collider.get_instance_id() != _last_collider_id:
			_last_collider_id = collider.get_instance_id()
			_move()
			_reduce_brick_hp()
			_check_hit_paddle()
	else:
		_last_collider_id = 0

func _check_hit_paddle() -> void:
	if collision_info.get_collider() is Player:
		num_of_coll_player += 1

func _reduce_brick_hp() -> void:
	if collision_info.get_collider() is StaticBody2D:
		var body : StaticBody2D = collision_info.get_collider()
		if body.is_in_group(GameConfig.GROUP_BRICK):
			level._reduce_block_hp(body)
