extends Control

class_name Games

@onready var pong: TextureButton = $Panel/GridContainer/Pong
@onready var bb_classic: TextureButton = $Panel/GridContainer/BBClassic
@onready var bb_modern: TextureButton = $Panel/GridContainer/BBModern
@onready var back: TextureButton = $Panel/GridContainer/Back

const ORIG_GAME_BUTTON_SIZE : Vector2 = Vector2(200,200)
const ORIG_BACK_BUTTON_SIZE : Vector2 = Vector2(128,128)

func _tween_button_press(node : TextureButton) -> void:
	var scale_to : Vector2 = node.custom_minimum_size * 0.9
	var tween : Tween = create_tween().set_parallel(true)
	tween.tween_property(node,"custom_minimum_size",scale_to,0.1)
	tween.tween_property(node,"modulate:a", 0.8,0.1)
	tween.connect("finished",tween.kill)

func _tween_button_release(node : TextureButton, orig_size : Vector2) -> void:
	var scale_to : Vector2 = orig_size
	var tween : Tween = create_tween().set_parallel(true)
	tween.tween_property(node,"custom_minimum_size",scale_to,0.1)
	tween.tween_property(node,"modulate:a", 1.0,0.1)
	tween.connect("finished",tween.kill)


func _on_pong_button_down() -> void:
	_tween_button_press(pong)


func _on_pong_button_up() -> void:
	_tween_button_release(pong,ORIG_GAME_BUTTON_SIZE)


func _on_bb_classic_button_down() -> void:
	_tween_button_press(bb_classic)


func _on_bb_classic_button_up() -> void:
	_tween_button_release(bb_classic,ORIG_GAME_BUTTON_SIZE)


func _on_bb_modern_button_down() -> void:
	_tween_button_press(bb_modern)


func _on_bb_modern_button_up() -> void:
	_tween_button_release(bb_modern,ORIG_GAME_BUTTON_SIZE)


func _on_back_button_down() -> void:
	_tween_button_press(back)


func _on_back_button_up() -> void:
	_tween_button_release(back,ORIG_BACK_BUTTON_SIZE)
