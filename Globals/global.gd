extends Node

class_name Globals

@export var color_a : Color
@export var color_b : Color
@export var color_c : Color
@export var color_d : Color
@export var color_e : Color

enum colors {color_a,color_b,color_c,color_d,color_e}

@export var chosen_color : colors

const SCENE_GROUPS : Dictionary = {
	"MainMenuUi" : [GameConfig.GROUP_MAIN_MENU_UI],
	"LevelPong" : [GameConfig.GROUP_LEVEL_PONG, GameConfig.GROUP_PLAYER, GameConfig.GROUP_BALL, GameConfig.GROUP_CPU],
	"LevelBbClassic" : [GameConfig.GROUP_LEVEL_BB_CLASSIC, GameConfig.GROUP_PLAYER, GameConfig.GROUP_BALL, GameConfig.GROUP_BRICK],
	"LevelBbModern" : [GameConfig.GROUP_LEVEL_BB_MODERN, GameConfig.GROUP_BB_MOD_PLAYER, GameConfig.GROUP_BRICK],
}

# group -> accepted class_name list (group may contain subclass instances)
const GROUP_SCRIPT_TYPES : Dictionary = {
	GameConfig.GROUP_BALL : [&"Ball", &"BallPong", &"BallBbClassic"],
}

# scene class_name -> {entity class_name : (collision_layer, collision_mask)}
const SCENE_COLLISIONS : Dictionary = {
	"LevelPong" : {
		"BallPong" : [GameConfig.LAYER_BALL, GameConfig.MASK_PONG_BALL],
		"CPU" : [GameConfig.LAYER_ENEMY, GameConfig.MASK_WALL],
		"Player" : [GameConfig.LAYER_PLAYER, 0],
	},
	"LevelBbClassic" : {
		"BallBbClassic" : [GameConfig.LAYER_BALL, GameConfig.MASK_BB_CLASSIC_BALL],
		"Player" : [GameConfig.LAYER_PLAYER, GameConfig.MASK_PLAYER],
	},
	"LevelBbModern" : {
		"BbModPlayer" : [GameConfig.LAYER_BB_MOD_PLAYER, GameConfig.MASK_BB_MOD_PLAYER],
	},
}

func _ready() -> void:
	OS.request_permissions()
	call_deferred("_check_scene_groups")

func _check_scene_groups() -> void:
	var scene_root : Node = get_tree().current_scene
	if scene_root == null:
		return
	var scene_type : StringName = &""
	if scene_root.get_script() != null:
		var scene_script : Script = scene_root.get_script() as Script
		scene_type = scene_script.get_global_name()
	var expected : Array = SCENE_GROUPS.get(scene_type, [])
	for group : StringName in expected:
		var node : Node = get_tree().get_first_node_in_group(group)
		if node == null:
			push_warning("Group '" + group + "' has no nodes in scene " + scene_type)
			continue
		var script : Script = node.get_script()
		if script != null:
			var class_type : StringName = script.get_global_name()
			var allowed : Array = GROUP_SCRIPT_TYPES.get(group, [group])
			if not class_type in allowed:
				push_warning("Group '" + group + "' node '" + node.name + "' does not match class_name " + group)
		_check_entity_collision(node, script, scene_type)

func _check_entity_collision(node : Node, script : Script, scene_type : StringName) -> void:
	if script == null:
		return
	var class_type : StringName = script.get_global_name()
	var scene_entities : Dictionary = SCENE_COLLISIONS.get(scene_type, {})
	if not scene_entities.has(class_type):
		return
	var expected : Array = scene_entities[class_type]
	var coll : CollisionObject2D = node as CollisionObject2D
	if coll == null:
		return
	if coll.collision_layer != expected[0] or coll.collision_mask != expected[1]:
		push_warning("Entity '" + class_type + "' node '" + node.name + "' has collision_layer/mask " + str(coll.collision_layer) + "/" + str(coll.collision_mask) + ", expected " + str(expected[0]) + "/" + str(expected[1]))

func _choose_color() -> Color:
	match chosen_color:
		colors.color_a:
			return color_a
		colors.color_b:
			return color_b
		colors.color_c:
			return color_c
		colors.color_d:
			return color_d
		colors.color_e:
			return color_e
		_:
			return Color.ALICE_BLUE
