extends Entity

class_name Ball

var original_position : Vector2 = Vector2.ZERO
var player : Player

func _physics_process(delta: float) -> void:
	collision_info = move_and_collide(velocity * delta)
	if collision_info:
		Input.vibrate_handheld(5, 0.3)

func _move() -> void:
	direction = (direction.bounce(collision_info.get_normal())).normalized()
	velocity = direction * speed
