extends Ball

class_name BallBbClassic

signal bb_classic_next_level
signal brick_hit(body: StaticBody2D)

@export var player_ref : Player
@export var level_ref : LevelBbClassic

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
	_resolve_refs()
	original_position.y = global_position.y

func _resolve_refs() -> void:
	if player_ref == null:
		player_ref = get_tree().get_first_node_in_group(GameConfig.GROUP_PLAYER) as Player
	if level_ref == null:
		level_ref = get_tree().get_first_node_in_group(GameConfig.GROUP_LEVEL_BB_CLASSIC) as LevelBbClassic
	player = player_ref
	level = level_ref

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if is_instance_valid(player):
		original_position.x = player.position.x
	if collision_info == null:
		_last_collider_id = 0

func _set_direction_move(aim_direction : Vector2) -> void:
	direction = aim_direction.normalized()
	velocity = direction * speed

func _on_collided() -> void:
	_bb_classic_mode()

func _bb_classic_mode() -> void:
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
			brick_hit.emit(body)
			if brick_hit.get_connections().is_empty() and level != null:
				level._reduce_block_hp(body)
