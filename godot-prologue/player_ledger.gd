extends Node

const TITLE := "res://front_desk.tscn"
const SAVE_PATH := "user://player_ledger.cfg"

var active_player := ""
var last_run: Dictionary = {}
var open_results := false
var save_path := SAVE_PATH
var _profiles := ConfigFile.new()
var _load_error := OK


func _ready() -> void:
	_load_error = _profiles.load(save_path)
	if _load_error == ERR_FILE_NOT_FOUND:
		_load_error = OK


func sign_in(nickname: String) -> Error:
	if _load_error != OK:
		return _load_error
	var display_name := nickname.strip_edges()
	if display_name.is_empty() or display_name.length() > 16:
		return ERR_INVALID_PARAMETER
	for index in display_name.length():
		var code := display_name.unicode_at(index)
		if code < 32 or code == 127 or code in [0x2028, 0x2029]:
			return ERR_INVALID_PARAMETER
	var id := display_name.to_lower().sha256_text()
	if not _profiles.has_section(id):
		_profiles.set_value(id, "name", display_name)
		var error := _save()
		if error != OK:
			_profiles.erase_section(id)
			return error
	if active_player != id:
		last_run.clear()
	active_player = id
	return OK


func player_names() -> PackedStringArray:
	var names := PackedStringArray()
	for id in _profiles.get_sections():
		names.append(player_name(id))
	names.sort()
	return names


func player_name(id: String) -> String:
	return str(_profiles.get_value(id, "name", "")) if _profiles.has_section(id) else ""


func complete_prologue(elapsed_ms: int, remaining_health: int) -> void:
	if active_player.is_empty():
		return
	var score := 1000 + clampi(remaining_health, 0, 100) * 6 + maxi(0, 900 - elapsed_ms / 1000)
	last_run = {"score": score, "time": elapsed_ms, "saved": false}
	_save_best()


func format_time(milliseconds: int) -> String:
	var seconds := milliseconds / 1000
	return "%02d:%02d.%03d" % [seconds / 60, seconds % 60, milliseconds % 1000]


func _save_best() -> void:
	var previous: Dictionary = _profiles.get_value(active_player, "best", {})
	var next := {"score": last_run.score, "time": last_run.time}
	if not previous.is_empty() and not _ranks_before(next, previous):
		last_run.saved = true
		return
	_profiles.set_value(active_player, "best", next)
	last_run.saved = _save() == OK
	if not last_run.saved:
		if previous.is_empty():
			_profiles.erase_section_key(active_player, "best")
		else:
			_profiles.set_value(active_player, "best", previous)


func leaderboard() -> Array[Dictionary]:
	var entries: Array[Dictionary] = []
	for id in _profiles.get_sections():
		var best: Dictionary = _profiles.get_value(id, "best", {})
		if not best.is_empty():
			entries.append({"id": id, "name": player_name(id), "score": best.score, "time": best.time})
	entries.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		if a.score == b.score and a.time == b.time:
			return a.name.naturalnocasecmp_to(b.name) < 0
		return _ranks_before(a, b)
	)
	return entries


func _ranks_before(a: Dictionary, b: Dictionary) -> bool:
	return a.score > b.score or (a.score == b.score and a.time < b.time)


func _save() -> Error:
	var pending := save_path + ".tmp"
	var error := _profiles.save(pending)
	if error != OK:
		return error
	return DirAccess.rename_absolute(pending, save_path)
