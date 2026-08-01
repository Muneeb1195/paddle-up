extends Control

class_name Games

@onready var pong: TextureButton = $Panel/GridContainer/Pong
@onready var bb_classic: TextureButton = $Panel/GridContainer/BBClassic
@onready var bb_modern: TextureButton = $Panel/GridContainer/BBModern
@onready var back: Button = $Panel/GridContainer/Back

const ORIG_GAME_BUTTON_SIZE : Vector2 = Vector2(200,200)
const ORIG_BACK_BUTTON_SIZE : Vector2 = Vector2(200,200)

func _ready() -> void:
	pong.mouse_entered.connect(ButtonTweenHelper.hover_enter.bind(pong))
	pong.mouse_exited.connect(ButtonTweenHelper.hover_exit.bind(pong))
	bb_classic.mouse_entered.connect(ButtonTweenHelper.hover_enter.bind(bb_classic))
	bb_classic.mouse_exited.connect(ButtonTweenHelper.hover_exit.bind(bb_classic))
	bb_modern.mouse_entered.connect(ButtonTweenHelper.hover_enter.bind(bb_modern))
	bb_modern.mouse_exited.connect(ButtonTweenHelper.hover_exit.bind(bb_modern))
	back.mouse_entered.connect(ButtonTweenHelper.hover_enter.bind(back))
	back.mouse_exited.connect(ButtonTweenHelper.hover_exit.bind(back))

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
