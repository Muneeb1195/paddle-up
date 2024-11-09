extends Control

class_name DifficultyMenu

@onready var easy: Button = $VBoxContainer/Easy
@onready var medium: Button = $VBoxContainer/Medium
@onready var hard: Button = $VBoxContainer/Hard
@onready var global : Globals = Global
@onready var label: Label = $Label

func _ready() -> void:
	modulate = global.color_d
