extends CharacterBody2D

class_name Entity

@export var speed : float = 1000

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var global : Globals = Global

var collision_info : KinematicCollision2D
var direction : Vector2

func _ready() -> void:
	sprite_2d.modulate = global._choose_color()
