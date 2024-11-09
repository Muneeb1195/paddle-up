extends StaticBody2D

class_name  Brick

@onready var hit_points: Label = $HitPoints
@onready var sprite_2d: Sprite2D = $Sprite2D

const reduce_by : int = 1
var brick_rotation : float

var hp : int :
	set(value):
		hp = value
		hit_points.text = "%2d" % [hp]
		if hp <= 0:
			queue_free()

func _ready() -> void:
	if get_child(2) is CollisionPolygon2D and get_child_count() == 3:
		_rotate_brick(brick_rotation)

func _set_hp_n_color(value: int, color : Color) -> void:
	await ready
	hp = value
	sprite_2d.modulate = color

func _reduce_hp() -> void:
	hp -= reduce_by

func _rotate_brick(value : float) -> void:
	var collision_polygon : CollisionPolygon2D = $CollisionPolygon2D 
	collision_polygon.rotation = deg_to_rad(value)
	match value:
		90.0:
			hit_points.vertical_alignment = VERTICAL_ALIGNMENT_TOP
		180.0:
			hit_points.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			hit_points.vertical_alignment = VERTICAL_ALIGNMENT_TOP
		270.0:
			hit_points.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sprite_2d.rotation = deg_to_rad(value)
