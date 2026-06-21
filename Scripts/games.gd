extends Control

class_name Games

@onready var pong: TextureButton = $Panel/GridContainer/Pong
@onready var bb_classic: TextureButton = $Panel/GridContainer/BBClassic
@onready var bb_modern: TextureButton = $Panel/GridContainer/BBModern
@onready var back: TextureButton = $Panel/GridContainer/Back

const ORIG_GAME_BUTTON_SIZE : Vector2 = Vector2(200,200)
const ORIG_BACK_BUTTON_SIZE : Vector2 = Vector2(128,128)

func _on_pong_button_down() -> void:
	ButtonTweenHelper.press(pong)

func _on_pong_button_up() -> void:
	ButtonTweenHelper.release(pong, ORIG_GAME_BUTTON_SIZE)

func _on_bb_classic_button_down() -> void:
	ButtonTweenHelper.press(bb_classic)

func _on_bb_classic_button_up() -> void:
	ButtonTweenHelper.release(bb_classic, ORIG_GAME_BUTTON_SIZE)

func _on_bb_modern_button_down() -> void:
	ButtonTweenHelper.press(bb_modern)

func _on_bb_modern_button_up() -> void:
	ButtonTweenHelper.release(bb_modern, ORIG_GAME_BUTTON_SIZE)

func _on_back_button_down() -> void:
	ButtonTweenHelper.press(back)

func _on_back_button_up() -> void:
	ButtonTweenHelper.release(back, ORIG_BACK_BUTTON_SIZE)
