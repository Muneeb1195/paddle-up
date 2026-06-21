extends InGameUI

class_name PongUI

@export var win_screen_scene : PackedScene

@onready var cpu_points: Label = $MarginContainer/VBox/CpuPoints
@onready var player_points: Label = $MarginContainer/VBox/PlayerPoints
@onready var player: Player = get_tree().get_first_node_in_group("Player")
@onready var level_pong : LEVELPONG = get_tree().get_first_node_in_group("LevelPong")
@onready var difficulty_menu: DifficultyMenu = $DifficultyMenu

var _rally_label : Label
var _speed_label : Label
var _countdown_label : Label
var _score_flash_tween : Tween

func _ready() -> void:
	_tween_menu(difficulty_menu,margin_container)
	fade._pause_game()
	difficulty_menu.easy.pressed.connect(_start_game)
	difficulty_menu.medium.pressed.connect(_start_game)
	difficulty_menu.hard.pressed.connect(_start_game)
	_create_rally_ui()
	_create_speed_ui()
	_create_countdown_label()

func _create_rally_ui() -> void:
	_rally_label = Label.new()
	_rally_label.text = ""
	_rally_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_rally_label.add_theme_font_size_override("font_size", 32)
	_rally_label.modulate.a = 0.0
	_rally_label.position = Vector2(300, 50)
	_rally_label.size = Vector2(400, 40)
	add_child(_rally_label)

func _create_speed_ui() -> void:
	_speed_label = Label.new()
	_speed_label.text = ""
	_speed_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_speed_label.add_theme_font_size_override("font_size", 24)
	_speed_label.modulate.a = 0.0
	_speed_label.position = Vector2(300, 90)
	_speed_label.size = Vector2(400, 30)
	add_child(_speed_label)

func _create_countdown_label() -> void:
	_countdown_label = Label.new()
	_countdown_label.text = ""
	_countdown_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_countdown_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_countdown_label.add_theme_font_size_override("font_size", 128)
	_countdown_label.position = Vector2(250, 900)
	_countdown_label.size = Vector2(500, 200)
	add_child(_countdown_label)

func _start_game() -> void:
	_tween_menu(margin_container,difficulty_menu)
	fade._unpause_game()

func show_countdown(text : String) -> void:
	_countdown_label.text = text
	_countdown_label.scale = Vector2(2.0, 2.0)
	_countdown_label.modulate.a = 0.0
	var tween : Tween = create_tween().set_parallel(true)
	tween.tween_property(_countdown_label, "scale", Vector2.ONE, 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(_countdown_label, "modulate:a", 1.0, 0.15)
	tween.tween_interval(0.5)
	tween.chain().tween_property(_countdown_label, "modulate:a", 0.0, 0.15)

func hide_countdown() -> void:
	_countdown_label.text = ""

func update_rally(count : int) -> void:
	if count >= 3:
		_rally_label.text = "Rally: %d" % count
		_rally_label.modulate.a = 1.0
		if count >= 10:
			_rally_label.modulate = Color(1, 0.09, 0.267)
		elif count >= 5:
			_rally_label.modulate = Color(1, 0.8, 0.2)
		else:
			_rally_label.modulate = Color(0.85, 0.85, 0.85)
	else:
		_rally_label.modulate.a = 0.0

func update_speed_indicator(current_speed : int, base_speed : int) -> void:
	var ratio : float = float(current_speed) / float(base_speed)
	if ratio <= 1.0:
		_speed_label.modulate.a = 0.0
		return
	_speed_label.modulate.a = 1.0
	if ratio >= 2.5:
		_speed_label.text = ">>> MAX SPEED <<<"
		_speed_label.modulate = Color(1, 0.09, 0.267)
	elif ratio >= 2.0:
		_speed_label.text = ">> FAST >>"
		_speed_label.modulate = Color(1, 0.5, 0.0)
	elif ratio >= 1.5:
		_speed_label.text = "> QUICK >"
		_speed_label.modulate = Color(1, 0.8, 0.2)
	else:
		_speed_label.text = "Speeding Up..."
		_speed_label.modulate = Color(0.85, 0.85, 0.85)

func flash_score(cpu_scored : bool) -> void:
	if _score_flash_tween and _score_flash_tween.is_valid():
		_score_flash_tween.kill()
	var flash_color : Color = Color(1, 0.09, 0.267) if cpu_scored else Color(0.38, 0.90, 0.78)
	margin_container.modulate = flash_color
	_score_flash_tween = create_tween()
	_score_flash_tween.tween_property(margin_container, "modulate", Color.WHITE, 0.4).set_ease(Tween.EASE_OUT)

func _display_win_screen() -> void:
	var win_screen : WinScreen = win_screen_scene.instantiate()
	win_screen.hide()
	add_child(win_screen)
	_tween_menu(win_screen,margin_container)
	fade._pause_game()
	win_screen.home_button.pressed.connect(fade._change_scene.bind(fade.main_menu))
	win_screen.restart_button.pressed.connect(get_tree().reload_current_scene)
	win_screen.restart_button.pressed.connect(fade._unpause_game)
	win_screen.line_edit.text_submitted.connect(_submit_win_score)

func _display_lose_screen() -> void:
	super._display_lose_screen()
	global.pong_hs.append(["CPU Won By", level_pong.cpu_points - level_pong.player_points])
	global.pong_hs.sort()
	if global.pong_hs.size() > 5:
			global.pong_hs.resize(5)
	global.pong_high_scores = {"HighScores" : global.pong_hs}
	global._save_game(global.pong_hs_path, global.pong_high_scores)

func _submit_win_score(new_text : String) -> void:
	global.pong_hs.append([new_text + " Won By", level_pong.player_points - level_pong.cpu_points])
	global.pong_hs.sort()
	if global.pong_hs.size() > 5:
		global.pong_hs.resize(5)
	global.pong_high_scores = {"HighScores" : global.pong_hs}
	global._save_game(global.pong_hs_path, global.pong_high_scores)

func _on_pause_mouse_entered() -> void:
	player.set_process_input(false)
	player.set_physics_process(false)

func _on_pause_mouse_exited() -> void:
	player.set_process_input(true)
	player.set_physics_process(true)
