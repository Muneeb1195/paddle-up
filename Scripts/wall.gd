@tool

extends StaticBody2D

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
#@export var _shape_size: Vector2 = collision_shape_2d.shape.size:
	#set(value):
		#await ready
		#_shape_size = value
@export var shape_size :  Vector2:
	set(value):
		if get_child_count() != null and collision_shape_2d != null:
			shape_size = value
			collision_shape_2d.shape.size = value
