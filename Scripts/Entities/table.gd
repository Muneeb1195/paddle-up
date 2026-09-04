extends Node2D

class_name PongTable

@onready var wall: TileMapLayer = $Wall
@export var level_ref : LevelPong
@onready var level_pong : LevelPong = level_ref if level_ref != null else get_tree().get_first_node_in_group(GameConfig.GROUP_LEVEL_PONG) as LevelPong

signal player_point
signal enemy_point


func _on_player_point_body_entered(_body: Ball) -> void:
	player_point.emit()
	if player_point.get_connections().is_empty() and level_pong != null:
		level_pong._increase_player_point()


func _on_enemy_point_body_entered(_body: Ball) -> void:
	enemy_point.emit()
	if enemy_point.get_connections().is_empty() and level_pong != null:
		level_pong._increase_cpu_point()
