extends Node2D

class_name Trajectory

@export var FORCE : float = 1000

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
	for point : Vector2 in _cached_points:
		draw_texture(img, point)

func get_forward_direction() -> Vector2:
	return global_position.direction_to(get_global_mouse_position())

func _calculate_trajectory() -> void:
	_cached_points.clear()
	var velocity : Vector2 = FORCE * get_forward_direction()
	var pos : Vector2 = global_position
	var timestep : float = 0.05
	var bounce_count : int = 0
	var space_state : PhysicsDirectSpaceState2D = get_world_2d().direct_space_state
	var exclude_rids : Array[RID] = []

	var parent : Node = get_parent()
	while parent:
		if parent is CollisionObject2D:
			exclude_rids.append((parent as CollisionObject2D).get_rid())
		parent = parent.get_parent()

	for i : int in 35:
		var next_pos : Vector2 = pos + (velocity * timestep)
		var query : PhysicsRayQueryParameters2D = PhysicsRayQueryParameters2D.create(pos, next_pos, 145)
		query.exclude = exclude_rids
		var result : Dictionary = space_state.intersect_ray(query)

		if result:
			_cached_points.append(result["position"] - global_position)
			velocity = velocity.bounce(result["normal"])
			pos = result["position"]
			bounce_count += 1
			if bounce_count >= 2:
				break
		else:
			var mid_a : Vector2 = pos + Vector2(-8, -8) - global_position
			var mid_b : Vector2 = next_pos + Vector2(-8, -8) - global_position
			_cached_points.append(mid_a)
			_cached_points.append(mid_b)
			pos = next_pos
