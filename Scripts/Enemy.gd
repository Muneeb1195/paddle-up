extends Entity

class_name CPU

var acceleration : float
@export_range(1,20,1) var deceleration : float

@onready var ball : Ball =  get_tree().get_first_node_in_group("Ball")

const ORIGNAL_POS : Vector2 = Vector2(500,250)

var min_speed : float = 0.0
var y_dist : float
var minimum_detect_dist : int


func _process(delta: float) -> void:
	var previous_y_dist : float = y_dist
	y_dist = sqrt(pow(ball.position.y - position.y, 2))
	if y_dist < minimum_detect_dist and previous_y_dist - y_dist > 0:
		_get_predicted_ball_pos(delta)
	else:
		_move_back(delta)

func _physics_process(delta: float) -> void:
	move_and_collide(velocity * delta)

func _get_predicted_ball_pos(delta : float) -> void:
	var predicted_ball_position : Vector2 = Vector2(ball.predicted_x_position,position.y)
	if position.distance_to(predicted_ball_position) > 10:
		direction = position.direction_to(predicted_ball_position)
		_move(delta)
	else:
		_stop(delta)

func _move_back(delta : float) -> void:
	direction = position.direction_to(ORIGNAL_POS)
	if position.distance_to(ORIGNAL_POS) > 10:
		_move(delta)
	else:
		_stop(delta)

func _move(delta: float) -> void:
	velocity.x = lerp(velocity.x,direction.x * speed, acceleration * delta)

func _stop(delta : float) -> void:
	velocity.x = lerp(velocity.x, min_speed, deceleration * delta)
