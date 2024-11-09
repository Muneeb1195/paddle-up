extends StaticBody2D

class_name BBMODPLAYER

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var rail: Sprite2D = $Rail
@onready var paddle: Sprite2D = $Paddle
@onready var trajectory: Trajectory = $Paddle/Trajectory
@onready var half_rail_width : float = (rail.texture.get_width() * rail.scale.x)
@onready var half_paddle_width : float = (paddle.texture.get_width() * paddle.scale.x)/2
@onready var ball_spawner: Sprite2D = $Paddle/BallSpawner
@onready var global : Globals = Global
@onready var max_pos : float = half_rail_width - half_paddle_width-5

func _ready() -> void:
	paddle.modulate = global._choose_color()

func _move_paddle(pos_x: float) -> void:
	var clamped_position : float = clampf(pos_x,80,max_pos)
	var tween: Tween = create_tween()
	tween.tween_property(paddle, "global_position:x",clamped_position,0.25)
	tween.connect("finished",tween.kill)
