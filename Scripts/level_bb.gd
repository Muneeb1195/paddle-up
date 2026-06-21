extends Node2D

class_name LevelBB

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
var block_array : Array[StaticBody2D] = []
var block_hp_array : Array[int] = []
var block_y_pos_array : Array[float] = []
var block_index_map : Dictionary = {}
var _blocks_origin : Vector2
var _shake_tween : Tween

func _ready() -> void:
	_blocks_origin = blocks_node.position
	_prewarm_break_shader()
	create_block_field()
	_sort_blocks()

func _prewarm_break_shader() -> void:
	var mat : ShaderMaterial = ShaderMaterial.new()
	mat.shader = _break_shader
	mat.set_shader_parameter("progress", 0.0)
	var warmup : Sprite2D = Sprite2D.new()
	warmup.texture = preload("res://Assets/Ball/ball.png")
	warmup.material = mat
	add_child(warmup)
	warmup.queue_free()

func create_block_field() -> void:
	new_block_pos = BLOCK_START_POS
	for rows : int in STARTING_ROWS:
		_create_block_row()
		new_block_pos.x = BLOCK_START_POS.x
		new_block_pos.y += GRID_SIZE

func _rebuild_index_map() -> void:
	block_index_map.clear()
	for i : int in block_array.size():
		block_index_map[block_array[i].get_instance_id()] = i

func _sort_blocks() -> void:
	block_y_pos_array.clear()
	for block : StaticBody2D in block_array:
		block_y_pos_array.push_back(block.position.y)
	block_y_pos_array.sort()
	_rebuild_index_map()

func _create_block_row() -> void:
	for coloums : int in MAX_COLOUMS:
		var type : int = randi() % 4
		if not type == 3:
			var new_block : StaticBody2D = block_type[type].instantiate()
			new_block.position = new_block_pos
			block_hp_array.push_back(block_hp)
			block_array.push_back(new_block)
			block_index_map[new_block.get_instance_id()] = block_array.size() - 1
			blocks_node.add_child(new_block)
			var sprite : Sprite2D = new_block.get_child(0)
			var label : Label = new_block.get_child(1)
			sprite.modulate = global._choose_color()
			label.text = "%2d" % [block_hp]
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
	var tween : Tween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD).set_parallel(true)
	for old_bricks : StaticBody2D in blocks_node.get_children():
		tween.tween_property(old_bricks, "position:y", old_bricks.position.y + GRID_SIZE, 0.15)
	await tween.finished
	var count_before : int = block_array.size()
	_add_new_block_row()
	_sort_blocks()
	for i : int in range(count_before, block_array.size()):
		var brick : StaticBody2D = block_array[i]
		var target_y : float = brick.position.y
		brick.position.y -= GRID_SIZE
		brick.modulate.a = 0.0
		var spawn_tween : Tween = create_tween().set_parallel(true)
		spawn_tween.tween_property(brick, "position:y", target_y, 0.15)
		spawn_tween.tween_property(brick, "modulate:a", 1.0, 0.15)

func _add_new_block_row() -> void:
	new_block_pos = BLOCK_START_POS
	block_hp += 1
	_create_block_row()

var _break_shader : Shader = preload("res://Assets/Shaders/break.gdshader")

func _reduce_block_hp(block : StaticBody2D) -> void:
	if not block_index_map.has(block.get_instance_id()):
		return
	var label : Label = block.get_child(1)
	var array_pos : int = block_index_map[block.get_instance_id()]
	block_hp_array[array_pos] -= 1
	label.text = "%2d" % [block_hp_array[array_pos]]
	if block_hp_array[array_pos] < 1:
		block_array.remove_at(array_pos)
		block_hp_array.remove_at(array_pos)
		block_index_map.erase(block.get_instance_id())
		_shake_blocks()
		_play_break_effect.call_deferred(block)
		for idx : int in range(array_pos, block_array.size()):
			block_index_map[block_array[idx].get_instance_id()] = idx

func _play_break_effect(block : StaticBody2D) -> void:
	block.collision_layer = 0
	block.collision_mask = 0
	var sprite : Sprite2D = block.get_child(0)
	var mat : ShaderMaterial = ShaderMaterial.new()
	mat.shader = _break_shader
	mat.set_shader_parameter("progress", 0.0)
	mat.set_shader_parameter("twist", randf_range(1.0, 3.0))
	sprite.material = mat
	var tween : Tween = create_tween()
	tween.tween_property(mat, "shader_parameter/progress", 1.0, 0.25).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	tween.tween_callback(block.queue_free)

func _shake_blocks() -> void:
	if _shake_tween and _shake_tween.is_valid():
		_shake_tween.kill()
	_shake_tween = create_tween()
	_shake_tween.tween_property(blocks_node, "position", _blocks_origin + Vector2(randf_range(-4,4), randf_range(-4,4)), 0.04)
	_shake_tween.tween_property(blocks_node, "position", _blocks_origin + Vector2(randf_range(-3,3), randf_range(-3,3)), 0.04)
	_shake_tween.tween_property(blocks_node, "position", _blocks_origin, 0.04)

func _save_bricks() -> Array[Dictionary]:
	var saved_bricks : Array[Dictionary] = []
	var i : int = 0
	for brick : StaticBody2D in block_array:
		var sprite : Sprite2D = brick.get_child(0)
		saved_bricks.append({
			"filename" : brick.get_scene_file_path(),
			"parent" : brick.get_parent().get_path(),
			"pos_x" : brick.position.x,
			"pos_y" : brick.position.y,
			"hp" : block_hp_array[i],
			"rotation" : int(rad_to_deg(sprite.rotation))
		})
		i += 1
	return saved_bricks

func _load_bricks(data : Variant) -> void:
	if data is Dictionary:
		# Convert old dict format to new array format
		var converted : Array[Dictionary] = []
		for key : String in data:
			converted.append(data[key])
		data = converted
	for brick_data : Dictionary in data:
		var block_scene : PackedScene = load(brick_data["filename"])
		var block : StaticBody2D = block_scene.instantiate()
		block_array.push_back(block)
		block_hp_array.push_back(brick_data["hp"])
		block_y_pos_array.push_back(brick_data["pos_y"])
		blocks_node.add_child(block)
		var sprite : Sprite2D = block.get_child(0)
		var label : Label = block.get_child(1)
		block.position = Vector2(brick_data["pos_x"], brick_data["pos_y"])
		label.text = "%2d" % [brick_data["hp"]]
		if brick_data["rotation"] != 0:
			var rot : float = brick_data["rotation"]
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
	_sort_blocks()
