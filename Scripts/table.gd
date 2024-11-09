extends Node2D

class_name PONGTABLE

@onready var wall: TileMapLayer = $Wall
@onready var player_point: Area2D = $PlayerPoint
@onready var enemy_point: Area2D = $EnemyPoint
@onready var level_pong : LEVELPONG = get_tree().get_first_node_in_group("LevelPong")


func _on_player_point_body_entered(_body: Ball) -> void:
	level_pong._increase_player_point()


func _on_enemy_point_body_entered(_body: Ball) -> void:
	level_pong._increase_cpu_point()
