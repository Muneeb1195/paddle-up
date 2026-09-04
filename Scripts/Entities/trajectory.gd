extends Node2D

class_name Trajectory

@export var FORCE : float = 900
const TRAJECTORY_MASK : int = GameConfig.MASK_ALL

var img : CompressedTexture2D = preload("res://Assets/Ball/ball_outline.png")

# Substep length for the shape sweep; ~1 ball diameter keeps corner grazes honest.
const SIM_STEP_PX : float = 20.0
# Cached dots are strided so the guide reads as spaced markers; the sweep
# itself keeps full resolution for bounce accuracy. Contacts always cached.
const DOT_STRIDE : int = 3
const MAX_BOUNCES : int = 3
const MAX_STEPS : int = 120

var _circle : CircleShape2D = CircleShape2D.new()
var _cached_points : PackedVector2Array = PackedVector2Array()
# Exact direction used by the last simulation; the single value shared by
# drawing and shooting so the line can never disagree with the ball.
var _aim_dir : Vector2 = Vector2.UP
var _aim_dirty : bool = true

func _ready() -> void:
	_circle.radius = GameConfig.BALL_DIAMETER / 2.0
	hide()

func _process(_delta: float) -> void:
	if not visible:
		return
	_calculate_trajectory()
	queue_redraw()

func _draw() -> void:
	var dot_half : Vector2 = img.get_size() / 2.0
	for point : Vector2 in _cached_points:
		draw_texture(img, (point - dot_half).round())

func get_forward_direction() -> Vector2:
	var dir : Vector2 = global_position.direction_to(get_global_mouse_position())
	if dir == Vector2.ZERO:
		return Vector2.UP
	var clamped_angle : float = clampf(dir.angle(), -deg_to_rad(GameConfig.MAX_AIM_ANGLE), -deg_to_rad(GameConfig.MIN_AIM_ANGLE))
	return Vector2.from_angle(clamped_angle)

func get_shot_direction() -> Vector2:
	if _aim_dirty:
		_calculate_trajectory()
	return _aim_dir

func is_aim_valid() -> bool:
	return get_global_mouse_position().y < global_position.y

func _calculate_trajectory() -> void:
	_cached_points.clear()
	_aim_dir = get_forward_direction()
	_aim_dirty = false
	var velocity : Vector2 = FORCE * _aim_dir
	var step_dir : Vector2 = _aim_dir
	var step_len : float = SIM_STEP_PX
	var pos : Vector2 = global_position
	var bounce_count : int = 0
	var space_state : PhysicsDirectSpaceState2D = get_world_2d().direct_space_state

	var query : PhysicsShapeQueryParameters2D = PhysicsShapeQueryParameters2D.new()
	query.shape = _circle
	query.collision_mask = TRAJECTORY_MASK
	query.collide_with_bodies = true
	query.collide_with_areas = false
	var exclude_rids : Array[RID] = []
	var parent : Node = get_parent()
	while parent:
		if parent is CollisionObject2D:
			exclude_rids.append((parent as CollisionObject2D).get_rid())
		parent = parent.get_parent()
	query.exclude = exclude_rids

	for i : int in MAX_STEPS:
		var motion : Vector2 = step_dir * step_len
		query.transform = Transform2D(0.0, pos)
		query.motion = motion
		var result : PackedFloat32Array = space_state.cast_motion(query)
		var safe_fraction : float = result[0]
		if i % DOT_STRIDE == 0:
			_cached_points.append(pos - global_position)
		if safe_fraction < 1.0:
			var contact : Vector2 = pos + motion * safe_fraction
			_cached_points.append(contact - global_position)
			var rest_info : Dictionary = space_state.get_rest_info(query)
			if rest_info.is_empty():
				break
			var hit_normal : Vector2 = rest_info["normal"]
			velocity = velocity.bounce(hit_normal)
			step_dir = velocity.normalized()
			# Restart just off the surface so the next sweep starts clean.
			pos = contact + hit_normal * 1.0
			bounce_count += 1
			if bounce_count >= MAX_BOUNCES:
				break
		else:
			pos = pos + motion
	_aim_dirty = false
