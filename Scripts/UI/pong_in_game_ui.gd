extends InGameUI

class_name PongUI

@onready var cpu_points: Label = $MarginContainer/VBox/CpuPoints
@onready var player_points: Label = $MarginContainer/VBox/PlayerPoints
@export var player_ref : Player
@export var level_ref : LevelPong
@onready var player: Player = player_ref if player_ref != null else get_tree().get_first_node_in_group(GameConfig.GROUP_PLAYER) as Player
@onready var level_pong : LevelPong = level_ref if level_ref != null else get_tree().get_first_node_in_group(GameConfig.GROUP_LEVEL_PONG) as LevelPong
@onready var difficulty_menu: DifficultyMenu = $DifficultyMenu
@onready var rally_label: Label = $MarginContainer/VBox/RallyLabel
@onready var speed_label: Label = $MarginContainer/VBox/SpeedLabel
@onready var countdown_label: Label = $CountdownLabel

var _score_flash_tween : Tween

func _ready() -> void:
	_tween_menu(difficulty_menu,margin_container)
	fade._pause_game()
	difficulty_menu.easy.pressed.connect(_start_game)
	difficulty_menu.medium.pressed.connect(_start_game)
	difficulty_menu.hard.pressed.connect(_start_game)

func _start_game() -> void:
	_tween_menu(margin_container,difficulty_menu)
	fade._unpause_game()

func show_countdown(text : String) -> void:
	countdown_label.text = text
	countdown_label.visible = true
	countdown_label.scale = Vector2(2.0, 2.0)
	countdown_label.modulate = Color(1, 0.09, 0.267)
	countdown_label.modulate.a = 0.0
	var tween : Tween = create_tween().set_parallel(true)
	tween.tween_property(countdown_label, "scale", Vector2.ONE, 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(countdown_label, "modulate:a", 1.0, 0.15)
	tween.tween_interval(0.5)
	tween.chain().tween_property(countdown_label, "modulate:a", 0.0, 0.15)

func hide_countdown() -> void:
	countdown_label.text = ""
	countdown_label.visible = false

func update_rally(count : int) -> void:
	if count >= 3:
		rally_label.text = "Rally: %d" % count
		rally_label.visible = true
		rally_label.modulate.a = 1.0
		if count >= 10:
			rally_label.modulate = Color(1, 0.09, 0.267)
		elif count >= 5:
			rally_label.modulate = Color(0.8, 0.4, 0.0)
		else:
			rally_label.modulate = Color(0.85, 0.85, 0.85)
	else:
		rally_label.visible = false

func update_speed_indicator(current_speed : int, base_speed : int) -> void:
	var ratio : float = float(current_speed) / float(base_speed)
	if ratio <= 1.0:
		speed_label.visible = false
		return
	speed_label.visible = true
	if ratio >= 2.5:
		speed_label.text = ">>> MAX SPEED <<<"
		speed_label.modulate = Color(1, 0.09, 0.267)
	elif ratio >= 2.0:
		speed_label.text = ">> FAST >>"
		speed_label.modulate = Color(0.8, 0.2, 0.0)
	elif ratio >= 1.5:
		speed_label.text = "> QUICK >"
		speed_label.modulate = Color(0.8, 0.4, 0.0)
	else:
		speed_label.text = "Speeding Up..."
		speed_label.modulate = Color(0.85, 0.85, 0.85)

func flash_score(cpu_scored : bool) -> void:
	if _score_flash_tween and _score_flash_tween.is_valid():
		_score_flash_tween.kill()
	var flash_color : Color = Color(1, 0.09, 0.267) if cpu_scored else Color(0.38, 0.90, 0.78)
	margin_container.modulate = flash_color
	_score_flash_tween = create_tween()
	_score_flash_tween.tween_property(margin_container, "modulate", Color.WHITE, 0.4).set_ease(Tween.EASE_OUT)

func _display_win_screen() -> void:
	var end_screen : EndScreen = end_screen_scene.instantiate()
	end_screen.is_win = true
	end_screen.game_kind = SaveManager.GameKind.PONG
	end_screen.score = level_pong.player_points - level_pong.cpu_points
	end_screen.name_suffix = " Won By"
	end_screen.modulate.a = 0.0
	end_screen.hide()
	add_child(end_screen)
	_tween_menu(end_screen,margin_container)
	fade._pause_game()

func _display_lose_screen() -> void:
	save_manager.add_high_score(SaveManager.GameKind.PONG, "CPU Won By", level_pong.cpu_points - level_pong.player_points)
	super._display_lose_screen()

func _on_pause_mouse_entered() -> void:
	player.set_process_input(false)
	player.set_physics_process(false)

func _on_pause_mouse_exited() -> void:
	player.set_process_input(true)
	player.set_physics_process(true)
