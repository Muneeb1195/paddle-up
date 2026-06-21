extends Node2D

class_name Trajectory

@export var FORCE : float = 900
const TRAJECTORY_MASK : int = 145 # Layers 1, 5, 8 (Walls + Block + BBModPlayer)

var img : CompressedTexture2D = preload("res://Assets/Ball/ball_outline.png")

var _cached_points : PackedVector2Array = PackedVector2Array()
var _needs_update : bool = false

func _ready() -> void:
	hide()

func _input(event: InputEvent) -> void:
	if event is InputEventScreenDrag and visible:
		_needs_update = true

func _physics_process(_delta: float) -> void:
	if _needs_update:
		_needs_update = false
		_calculate_trajectory()
		queue_redraw()

func _draw() -> void:
	var ball_half : Vector2 = Vector2(10, 10)
	for point : Vector2 in _cached_points:
		draw_texture(img, point - ball_half)

func get_forward_direction() -> Vector2:
	return global_position.direction_to(get_global_mouse_position())

func _calculate_trajectory() -> void:
	_cached_points.clear()
	var velocity : Vector2 = FORCE * get_forward_direction()
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
