extends Node2D

class_name Trajectory

@export var FORCE : float = 900
const TRAJECTORY_MASK : int = GameConfig.MASK_ALL

var img : CompressedTexture2D = preload("res://Assets/Ball/ball_outline.png")

const AIM_SMOOTHING : float = 0.35

var _cached_points : PackedVector2Array = PackedVector2Array()
var _needs_update : bool = false
var _smoothed_dir : Vector2 = Vector2.ZERO

func _ready() -> void:
	hide()

func _input(event: InputEvent) -> void:
	if event is InputEventScreenDrag and visible:
		_needs_update = true

func _process(_delta: float) -> void:
	if not visible:
		_smoothed_dir = Vector2.ZERO
	if _needs_update:
		_needs_update = false
		_calculate_trajectory()
		queue_redraw()

func _draw() -> void:
	var ball_half : Vector2 = Vector2(10, 10)
	for point : Vector2 in _cached_points:
		draw_texture(img, (point - ball_half).round())

func get_forward_direction() -> Vector2:
	var dir : Vector2 = global_position.direction_to(get_global_mouse_position())
	if dir == Vector2.ZERO:
		return Vector2.UP
	var clamped_angle : float = clampf(dir.angle(), -deg_to_rad(GameConfig.MAX_AIM_ANGLE), -deg_to_rad(GameConfig.MIN_AIM_ANGLE))
	return Vector2.from_angle(clamped_angle)

func is_aim_valid() -> bool:
	return get_global_mouse_position().y < global_position.y

func _get_smoothed_direction() -> Vector2:
	var clamped_dir : Vector2 = get_forward_direction()
	if _smoothed_dir == Vector2.ZERO:
		_smoothed_dir = clamped_dir
	else:
		_smoothed_dir = _smoothed_dir.lerp(clamped_dir, AIM_SMOOTHING)
	return _smoothed_dir

func _calculate_trajectory() -> void:
	_cached_points.clear()
	var velocity : Vector2 = FORCE * _get_smoothed_direction()
	var pos : Vector2 = global_position
	var timestep : float = 0.064
	var bounce_count : int = 0
	var space_state : PhysicsDirectSpaceState2D = get_world_2d().direct_space_state
	var exclude_rids : Array[RID] = []
	var ball_radius : float = 10.0

	var parent : Node = get_parent()
	while parent:
		if parent is CollisionObject2D:
			exclude_rids.append((parent as CollisionObject2D).get_rid())
		parent = parent.get_parent()

	for i : int in 50:
		var next_pos : Vector2 = pos + (velocity * timestep)
		var query : PhysicsRayQueryParameters2D = PhysicsRayQueryParameters2D.create(pos, next_pos, TRAJECTORY_MASK)
		query.exclude = exclude_rids
		var result : Dictionary = space_state.intersect_ray(query)

		if result:
			var hit_pos : Vector2 = result["position"]
			var hit_normal : Vector2 = result["normal"]
			_cached_points.append(hit_pos - global_position + Vector2(2, 2))
			velocity = velocity.bounce(hit_normal)
			pos = hit_pos + hit_normal * ball_radius
			bounce_count += 1
			if bounce_count >= 3:
				break
		else:
			_cached_points.append(pos - global_position + Vector2(2, 2))
			_cached_points.append(next_pos - global_position + Vector2(2, 2))
			pos = next_pos
