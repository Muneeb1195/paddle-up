extends CanvasLayer

class_name Fader

@export var pong : PackedScene
@export var bb_classic : PackedScene
@export var bb_modern : PackedScene
@export var main_menu : PackedScene

@onready var color_rect: ColorRect = $ColorRect

func _ready() -> void:
	color_rect.modulate.a = 0.0

func  _fade_to_black() -> void:
	var tween : Tween = create_tween().set_trans(Tween.TRANS_QUAD)
	tween.tween_property(color_rect,"modulate:a",1.0,0.5).from_current()
	tween.connect("finished",tween.kill)

func _fade_half() -> void:
	var tween : Tween = create_tween().set_trans(Tween.TRANS_QUAD)
	tween.tween_property(color_rect,"modulate:a",0.5,0.5).from_current()
	tween.connect("finished",tween.kill)

func _fade_to_normal() -> void:
	var tween : Tween = create_tween().set_trans(Tween.TRANS_QUAD)
	tween.tween_property(color_rect,"modulate:a",0.0,0.5).from_current()
	tween.connect("finished",tween.kill)

func _quit_game() -> void:
	get_tree().quit()

func _pause_game() -> void:
	get_tree().paused = true
	_fade_half()

func _unpause_game() -> void:
	get_tree().paused = false
	_fade_to_normal()

func _change_scene(scene : PackedScene) -> void:
	_fade_to_black()
	await get_tree().create_timer(0.5).timeout
	get_tree().call_deferred(&"change_scene_to_packed",scene)
	await get_tree().create_timer(0.5).timeout
	_fade_to_normal()
	_unpause_game()
