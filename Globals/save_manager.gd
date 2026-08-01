extends Node

class_name SaveManagerApi

enum GameKind { PONG, BB_CLASSIC, BB_MODERN }

const SAVE_VERSION : int = 1
const MAX_HIGH_SCORES : int = 5

const SAVE_PATHS : Dictionary = {
	GameKind.PONG : "/PaddleUp/Pong/pong_hs.save",
	GameKind.BB_CLASSIC : "/PaddleUp/BB Classic/bb_clas.save",
	GameKind.BB_MODERN : "/PaddleUp/BB Modern/bb_mod.save",
}
const HIGH_SCORE_PATHS : Dictionary = {
	GameKind.PONG : "/PaddleUp/Pong/pong_hs.save",
	GameKind.BB_CLASSIC : "/PaddleUp/BB Classic/bb_clas_hs.save",
	GameKind.BB_MODERN : "/PaddleUp/BB Modern/bb_mod_hs.save",
}

var _root_dir : String = OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS)

var bb_mod_dict : Dictionary = {}
var bb_clas_dict : Dictionary = {}
var bb_mod_hs : Array = []
var bb_clas_hs : Array = []
var pong_hs : Array = []

func _ready() -> void:
	_make_directories()
	load_all()

func _make_directories() -> void:
	var make_dir : DirAccess = DirAccess.open(_root_dir)
	if not make_dir.dir_exists("PaddleUp"):
		make_dir.make_dir("PaddleUp")
	for sub : String in ["BB Modern", "BB Classic", "Pong"]:
		if not make_dir.dir_exists("PaddleUp/" + sub):
			make_dir.make_dir("PaddleUp/" + sub)

func load_all() -> void:
	bb_mod_dict = load_game_dict(GameKind.BB_MODERN)
	bb_clas_dict = load_game_dict(GameKind.BB_CLASSIC)
	bb_mod_hs = load_high_scores(GameKind.BB_MODERN)
	bb_clas_hs = load_high_scores(GameKind.BB_CLASSIC)
	pong_hs = load_high_scores(GameKind.PONG)

func load_game_dict(kind : GameKind) -> Dictionary:
	var raw : Variant = _read_file(SAVE_PATHS[kind])
	var dict : Dictionary = raw as Dictionary if raw is Dictionary else {}
	if dict.has("version"):
		var data : Variant = dict.get("data", {})
		return data as Dictionary if data is Dictionary else {}
	return dict

func load_high_scores(kind : GameKind) -> Array:
	var raw : Variant = _read_file(HIGH_SCORE_PATHS[kind])
	var entries : Array = raw as Array if raw is Array else []
	if raw is Dictionary:
		var dict : Dictionary = raw as Dictionary
		var data : Variant = dict.get("data", null) if dict.has("version") else dict.get("HighScores", null)
		if data is Array:
			entries = data as Array
	var valid : Array = []
	for entry : Variant in entries:
		var entry_arr : Array = entry as Array if entry is Array else null
		if entry_arr != null and entry_arr.size() >= 2 and entry_arr[0] is String and (entry_arr[1] is int or entry_arr[1] is float):
			valid.append([entry_arr[0], int(entry_arr[1])])
	return valid

func save_dict(kind : GameKind, dict : Dictionary) -> void:
	_write_file(SAVE_PATHS[kind], {"version" : SAVE_VERSION, "data" : dict})

func save_high_scores(kind : GameKind) -> void:
	_write_file(HIGH_SCORE_PATHS[kind], {"version" : SAVE_VERSION, "data" : _hs_array(kind)})

func get_high_scores(kind : GameKind) -> Array:
	return _hs_array(kind)

func add_high_score(kind : GameKind, player_name : String, score : int) -> void:
	var arr : Array = _hs_array(kind)
	arr.append([player_name, score])
	arr.sort_custom(func(a: Array, b: Array) -> bool: return a[1] > b[1])
	if arr.size() > MAX_HIGH_SCORES:
		arr.resize(MAX_HIGH_SCORES)
	save_high_scores(kind)

func _hs_array(kind : GameKind) -> Array:
	match kind:
		GameKind.PONG:
			return pong_hs
		GameKind.BB_CLASSIC:
			return bb_clas_hs
		GameKind.BB_MODERN:
			return bb_mod_hs
	return []

func _read_file(path : String) -> Variant:
	var full_path : String = _root_dir + path
	if not FileAccess.file_exists(full_path):
		return null
	var save_file : FileAccess = FileAccess.open(full_path, FileAccess.READ)
	if save_file == null:
		push_warning("Failed to open save file: " + full_path)
		return null
	var json_string : String = save_file.get_line()
	save_file.close()
	if json_string.is_empty():
		return null
	var json : JSON = JSON.new()
	var parse_result : Error = json.parse(json_string)
	if parse_result != OK:
		push_warning("Save parse error in " + full_path + ": " + json.get_error_message())
		return null
	return json.get_data()

func _write_file(path : String, content : Variant) -> void:
	var full_path : String = _root_dir + path
	var save_file : FileAccess = FileAccess.open(full_path, FileAccess.WRITE)
	if save_file == null:
		push_error("Failed to open save file for writing: " + full_path)
		return
	save_file.store_line(JSON.stringify(content))
	save_file.close()
