extends InGameUI

class_name BBModInGameUi

@onready var level: Label = $MarginContainer/VBox/Level
@onready var time: Label = $MarginContainer/VBox/Time
@onready var level_bb_modern : LEVELBBMODERN = get_tree().get_first_node_in_group(&"LevelBBModern")
@onready var balls : BallsBB = get_tree().get_first_node_in_group(&"BallsBB")
@onready var line_edit: LineEdit = $LineEdit
@onready var retrive_balls: Button = $MarginContainer/RetriveBalls

func _on_lose() -> void:
	global.bb_mod_dict.clear()
	global._save_game(global.bb_mod_sav_path,global.bb_mod_dict)
	fade._pause_game()
	_tween_menu(line_edit, margin_container)

#func _on_pause_pressed() -> void:
	#if not line_edit.visible:
		#super._on_pause_pressed()
		#level_bb_modern._save()

func _on_restart_level() -> void:
	global.bb_mod_dict.clear()

func _on_pause_mouse_entered() -> void:
	level_bb_modern.set_process_input(false)
	level_bb_modern.trajectory_line.hide()

func _on_pause_mouse_exited() -> void:
	level_bb_modern.set_process_input(true)


func _on_line_edit_text_submitted(new_text: String) -> void:
	global.bb_mod_hs.append([new_text,level_bb_modern.level])
	global.bb_mod_hs.sort()
	if global.bb_mod_hs.size() > 5:
		global.bb_mod_hs.resize(5)
	global.bb_mod_high_scores = {"HighScores" : global.bb_mod_hs}
	global._save_game(global.bb_mod_hs_path, global.bb_mod_high_scores)
	line_edit.text = new_text
	line_edit.hide()
	_display_lose_screen()


func _on_retrive_balls_pressed() -> void:
	retrive_balls.disabled = true
	var speed : int = 1000
	for ball : RigidBody2D in balls.get_children():
		var dir : Vector2 = ball.position.direction_to(level_bb_modern.bb_mod_player.position)
		ball.linear_velocity = dir * speed
