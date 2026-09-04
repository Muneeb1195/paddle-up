extends Entity

class_name Player

@export var wall_position : Vector2 = Vector2(100,900)

var _dragging : bool = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"HoldnShoot"):
		_dragging = true
	elif event.is_action_released(&"HoldnShoot"):
		_dragging = false

func _physics_process(delta: float) -> void:
	if _dragging and get_global_mouse_position().y > global_position.y - 100:
		global_position.x = lerpf(global_position.x,clampf(get_global_mouse_position().x,wall_position.x,wall_position.y),10 * delta)
