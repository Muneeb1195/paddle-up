extends Control

class_name Games

@onready var pong: Button = $Panel/GridContainer/Pong
@onready var bb_classic: Button = $Panel/GridContainer/BBClassic
@onready var bb_modern: Button = $Panel/GridContainer/BBModern
@onready var back: Button = $Panel/GridContainer/Back

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
	ButtonTweenHelper.release(pong)

func _on_bb_classic_button_down() -> void:
	ButtonTweenHelper.press(bb_classic)

func _on_bb_classic_button_up() -> void:
	ButtonTweenHelper.release(bb_classic)

func _on_bb_modern_button_down() -> void:
	ButtonTweenHelper.press(bb_modern)

func _on_bb_modern_button_up() -> void:
	ButtonTweenHelper.release(bb_modern)

func _on_back_button_down() -> void:
	ButtonTweenHelper.press(back)

func _on_back_button_up() -> void:
	ButtonTweenHelper.release(back)
