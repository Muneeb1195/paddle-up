extends StaticBody2D

class_name BbModPlayer

@onready var rail: Sprite2D = $Rail
@onready var paddle: Sprite2D = $Paddle
@onready var trajectory: Trajectory = $Paddle/Trajectory
@onready var rail_width : float = (rail.texture.get_width() * rail.scale.x)
@onready var half_paddle_width : float = (paddle.texture.get_width() * paddle.scale.x)/2
@onready var global : Globals = Global

func _ready() -> void:
	paddle.modulate = global._choose_color()

func _get_max_pos() -> float:
	return rail_width - half_paddle_width - 5

var _paddle_tween : Tween

func _move_paddle(pos_x: float) -> void:
	var clamped_position : float = clampf(pos_x, GameConfig.PADDLE_MIN_X, _get_max_pos())
	if _paddle_tween and _paddle_tween.is_valid():
		_paddle_tween.kill()
	_paddle_tween = create_tween()
	_paddle_tween.tween_property(paddle, "global_position:x", clamped_position, 0.25)
