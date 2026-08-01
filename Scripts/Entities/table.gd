extends Node2D

class_name PongTable

@onready var wall: TileMapLayer = $Wall
@onready var level_pong : LevelPong = get_tree().get_first_node_in_group(GameConfig.GROUP_LEVEL_PONG)


func _on_player_point_body_entered(_body: Ball) -> void:
	level_pong._increase_player_point()


func _on_enemy_point_body_entered(_body: Ball) -> void:
	level_pong._increase_cpu_point()
