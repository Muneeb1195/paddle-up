extends Entity

class_name CPU

var acceleration : float
@export_range(1,20,1) var deceleration : float

@onready var ball : Ball =  get_tree().get_first_node_in_group("Ball")

const ORIGNAL_POS : Vector2 = Vector2(500,250)

var min_speed : float = 0.0
var y_dist : float
var minimum_detect_dist : int

var prediction_error : float = 0.0
var reaction_delay : float = 0.0
var _delay_timer : float = 0.0
var _pending_target_x : float = 0.0
var _has_pending_target : bool = false
var jitter_amplitude : float = 0.0
var _jitter_offset : float = 0.0
var _jitter_timer : float = 0.0


func _process(delta: float) -> void:
	_jitter_timer += delta
	_jitter_offset = sin(_jitter_timer * 3.0) * jitter_amplitude

	if _has_pending_target:
		_delay_timer += delta
		if _delay_timer >= reaction_delay:
			_has_pending_target = false
			_delay_timer = 0.0

	var previous_y_dist : float = y_dist
	y_dist = sqrt(pow(ball.position.y - position.y, 2))
	if y_dist < minimum_detect_dist and previous_y_dist - y_dist > 0:
		if _has_pending_target:
			_move_back(delta)
		else:
			_get_predicted_ball_pos(delta)
	else:
		_move_back(delta)

func _physics_process(delta: float) -> void:
	move_and_collide(velocity * delta)

func _get_predicted_ball_pos(delta : float) -> void:
	var error_x : float = randf_range(-prediction_error, prediction_error)
	var predicted_ball_position : Vector2 = Vector2(ball.predicted_x_position + error_x + _jitter_offset, position.y)
	if position.distance_to(predicted_ball_position) > 10:
		direction = position.direction_to(predicted_ball_position)
		_move(delta)
	else:
		_stop(delta)

func trigger_reaction_delay(predicted_x : float) -> void:
	_has_pending_target = true
	_pending_target_x = predicted_x
	_delay_timer = 0.0

func _move_back(delta : float) -> void:
	direction = position.direction_to(ORIGNAL_POS)
	if position.distance_to(ORIGNAL_POS) > 10:
		_move(delta)
	else:
		_stop(delta)

func _move(delta: float) -> void:
	velocity.x = lerp(velocity.x, direction.x * speed, acceleration * delta)

func _stop(delta : float) -> void:
	velocity.x = lerp(velocity.x, min_speed, deceleration * delta)

func configure(difficulty : int, rally : int) -> void:
	match difficulty:
		0: # Easy
			minimum_detect_dist = 600
			acceleration = 1.2
			prediction_error = 100.0
			reaction_delay = 0.25
			jitter_amplitude = 15.0
		1: # Medium
			minimum_detect_dist = 700
			acceleration = 2.0
			prediction_error = 50.0
			reaction_delay = 0.15
			jitter_amplitude = 8.0
		2: # Hard
			minimum_detect_dist = 850
			acceleration = 3.0
			prediction_error = 20.0
			reaction_delay = 0.05
			jitter_amplitude = 3.0

	var rally_factor : float = clampf(rally / 20.0, 0.0, 1.0)
	prediction_error = lerpf(prediction_error, prediction_error * 0.3, rally_factor)
	reaction_delay = lerpf(reaction_delay, reaction_delay * 0.3, rally_factor)
	minimum_detect_dist = int(lerpf(minimum_detect_dist, minimum_detect_dist * 1.3, rally_factor))
	jitter_amplitude = lerpf(jitter_amplitude, jitter_amplitude * 0.3, rally_factor)
