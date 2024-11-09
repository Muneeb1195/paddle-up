extends Node

class_name Globals

@export var color_a : Color
@export var color_b : Color
@export var color_c : Color
@export var color_d : Color
@export var color_e : Color

enum colors {color_a,color_b,color_c,color_d,color_e}

@export var chosen_color : colors

var save_path : String = OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS)
var bb_mod_sav_path : String = "/PaddleUp/BB Modern/bb_mod.save"
var bb_mod_hs_path : String = "/PaddleUp/BB Modern/bb_mod_hs.save"
var bb_clas_sav_path : String = "/PaddleUp/BB Classic/bb_clas.save"
var bb_clas_hs_path : String = "/PaddleUp/BB Classic/bb_clas_hs.save"
var pong_hs_path : String = "/PaddleUp/Pong/pong_hs.save"

var bb_mod_dict : Dictionary
var bb_mod_hs : Array
var bb_mod_high_scores : Dictionary

var bb_clas_dict : Dictionary
var bb_clas_hs : Array
var bb_clas_high_scores : Dictionary

var pong_hs : Array
var pong_high_scores : Dictionary

func _ready() -> void:
	OS.request_permissions()
	_make_directories()
	_load_saves()

func _make_directories() -> void:
	var make_dir : DirAccess = DirAccess.open(OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS))
	if not make_dir.dir_exists("PaddleUp"):
		make_dir.make_dir("PaddleUp")
		make_dir.make_dir("PaddleUp/BB Modern")
		make_dir.make_dir("PaddleUp/BB Classic")
		make_dir.make_dir("PaddleUp/Pong")

func _load_saves() -> void:
	bb_mod_dict = _load_game(bb_mod_sav_path)
	bb_clas_dict = _load_game(bb_clas_sav_path)
	pong_high_scores =_load_game(pong_hs_path)
	bb_clas_high_scores = _load_game(bb_clas_hs_path)
	if pong_high_scores:
		pong_hs = pong_high_scores["HighScores"]
	if bb_clas_high_scores:
		bb_clas_hs = bb_clas_high_scores["HighScores"]

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

func _save_game(path : String, dict : Dictionary) -> void:
	var save_file : FileAccess = FileAccess.open(save_path + path, FileAccess.WRITE)
	var save_dict : Dictionary
	if dict:
		save_dict = dict
		var json_string : String = JSON.stringify(save_dict)
		save_file.store_line(json_string)

func _load_game(path : String) -> Dictionary:
	if not FileAccess.file_exists(save_path + path):
		return {}
	
	var save_file : FileAccess = FileAccess.open(save_path + path, FileAccess.READ)
	var json_string : String = save_file.get_line()
	# Creates the helper class to interact with JSON.
	var json : JSON = JSON.new()
		# Check if there is any error while parsing the JSON string, skip in case of failure.
	var parse_result : Error = json.parse(json_string)
	if parse_result == OK:
		var dict : Dictionary = json.get_data()
		return dict
	else:
		print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
		return {}
