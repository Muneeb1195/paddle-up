extends Entity

class_name Player

@export var wall_position : Vector2 = Vector2(100,900)

func _process(delta: float) -> void:
	if Input.is_action_pressed(&"HoldnShoot") and get_global_mouse_position().y > global_position.y - 100:
		global_position.x = lerpf(global_position.x,clampf(get_global_mouse_position().x,wall_position.x,wall_position.y),10 * delta)
