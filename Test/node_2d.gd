extends Node2D

@export_group("Packed Scenes")
@export_subgroup("Bricks")
@export var square_brick : PackedScene
@export var triangle_brick : PackedScene
@export var circle_brick : PackedScene

@onready var blocks_node: Node2D = $Blocks
@onready var global : Globals = Global
@onready var block_type : Array[PackedScene] = [square_brick,triangle_brick,circle_brick]

const GRID_SIZE : int = 100
const BLOCK_START_POS : Vector2 = Vector2(50,200)
const MAX_COLOUMS : int = 10
const STARTING_ROWS : int = 8

var block_hp : int = 1
var new_block_pos : Vector2
var block_rotation : Array[int] = [0,90,180,270]
var block_array : Array
var block_hp_array : Array
var block_y_pos_array : Array

func _ready() -> void:
	randomize()
	create_block_field()
	_sort_blocks()

func create_block_field() -> void:
	new_block_pos = BLOCK_START_POS
	for rows : int in range(STARTING_ROWS):
		_create_block_row()
		new_block_pos.x = BLOCK_START_POS.x
		new_block_pos.y += GRID_SIZE

func _sort_blocks() -> void:
	block_y_pos_array.sort_custom(_sort_by_y_pos)

func _sort_by_y_pos(a: float, b: float) -> bool:
	if a < b:
		return true
	return false

func _create_block_row() -> void:
	for coloums : int in range(MAX_COLOUMS):
		var type : int = randi() % 4
		if not type == 3:
			var new_block : StaticBody2D = block_type[type].instantiate()
			new_block.position = new_block_pos
			block_y_pos_array.push_back(new_block_pos.y)
			block_hp_array.push_back(block_hp)
			block_array.push_back(new_block)
			blocks_node.add_child(new_block)
			var sprite : Sprite2D = new_block.get_child(0)
			var label : Label = new_block.get_child(1)
			sprite.modulate = global._choose_color()
			label.text = "%2d" % [block_hp]
			#_reduce_hp(new_block)
			if type == 1:
				var rot : float = block_rotation.pick_random()
				var coll_shape : CollisionPolygon2D = new_block.get_child(2)
				sprite.rotate(deg_to_rad(rot))
				coll_shape.rotate(deg_to_rad(rot))
				match rot:
					90.0:
						label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
					180.0:
						label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
						label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
					270.0:
						label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		new_block_pos.x += GRID_SIZE

func _move_old_blocks() -> void:
	for old_bricks : Brick in blocks_node.get_children():
		old_bricks.position.y += GRID_SIZE
	_add_new_block_row()
	_sort_blocks()

func _add_new_block_row() -> void:
	new_block_pos = BLOCK_START_POS
	block_hp += 1
	_create_block_row()

func _reduce_block_hp(block : StaticBody2D) -> void:
	var label : Label = block.get_child(1)
	var array_pos : int = block_array.find(block)
	block_hp_array[array_pos] -= 1
	label.text = "%2d" % [block_hp_array[array_pos]]
	if block_hp_array[array_pos] <= 0:
		block_array.erase(array_pos)
		block_y_pos_array.erase(array_pos)
		block_hp_array.erase(array_pos)
		block.queue_free()

func _save_bricks() -> Dictionary:
	var brick_dict: Dictionary
	var i : int = 0
	for brick : StaticBody2D in block_array:
		var sprite : Sprite2D = brick.get_child(0)
		brick_dict[brick.name] = {
			"filename" : brick.get_scene_file_path(),
			"parent" : brick.get_parent().get_path(),
			"pos_x" : brick.position.x, # Vector2 is not supported by JSON
			"pos_y" : brick.position.y,
			"hp" : block_hp_array[i],
			"rotation" : int(rad_to_deg(sprite.rotation))
		}
		i += 1
	return brick_dict

func _load_bricks(dict : Dictionary) -> void:
	var block_dict : Dictionary = dict
	for block_data : String in block_dict:
		var block_scene : PackedScene = load(block_dict[block_data]["filename"])
		var block : StaticBody2D = block_scene.instantiate()
		block_array.push_back(block)
		block_hp_array.push_back(block_dict[block_data]["hp"])
		block_y_pos_array.push_back(block_dict[block_data]["pos_y"])
		blocks_node.add_child(block)
		var sprite : Sprite2D = block.get_child(0)
		var label : Label = block.get_child(1)
		block.position = Vector2(block_dict[block_data]["pos_x"],block_dict[block_data]["pos_y"])
		label.text = "%2d" % [block_dict[block_data]["hp"]]
		if block_dict[block_data]["rotation"] != 0:
			var rot : float = block_dict[block_data]["rotation"]
			var coll_shape : CollisionPolygon2D = block.get_child(2)
			sprite.rotate(deg_to_rad(rot))
			coll_shape.rotate(deg_to_rad(rot))
			match rot:
				90.0:
					label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
				180.0:
					label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
					label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
				270.0:
					label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		sprite.modulate = global._choose_color()
