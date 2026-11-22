extends Node

enum Track { TITLE, ROAD, BOSS, VICTORY, DEFEAT }
enum Cue { UNROLL, SEAL, PARRY }

const TRACKS: Array[AudioStreamOggVorbis] = [
	preload("res://art/audio/title_scroll.ogg"),
	preload("res://art/audio/prologue_road.ogg"),
	preload("res://art/audio/boss_mo_mei.ogg"),
	preload("res://art/audio/victory.ogg"),
	preload("res://art/audio/defeat_fallen_ink.ogg"),
]
const CUES: Array[AudioStream] = [
	preload("res://art/audio/paper_unroll.ogg"),
	preload("res://art/audio/seal.ogg"),
	preload("res://art/audio/ink_parry.ogg"),
]
const TRACK_GAIN := -13.0
const MUTE := -55.0

var current_track := -1
var _players: Array[AudioStreamPlayer] = []
var _active := 0
var _crossfade: Tween
var _cues := AudioStreamPlayer.new()


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for index in 2:
		var player := AudioStreamPlayer.new()
		player.volume_db = MUTE
		add_child(player)
		_players.append(player)
	_cues.volume_db = -13.0
	add_child(_cues)


func music(track: Track) -> void:
	if current_track == track:
		return
	current_track = track
	if _crossfade:
		_crossfade.kill()
	var outgoing := _players[_active]
	_active = 1 - _active
	var incoming := _players[_active]
	var stream := TRACKS[track].duplicate() as AudioStreamOggVorbis
	var is_result := track == Track.VICTORY or track == Track.DEFEAT
	stream.loop = not is_result
	incoming.stream = stream
	incoming.volume_db = MUTE
	incoming.play()
	var duration := 0.45 if is_result else 1.0
	_crossfade = create_tween().set_ignore_time_scale(true).set_parallel(true)
	_crossfade.tween_property(outgoing, "volume_db", MUTE, duration)
	_crossfade.tween_property(incoming, "volume_db", TRACK_GAIN, duration * 0.67)
	_crossfade.chain().tween_callback(outgoing.stop)


func cue(id: Cue) -> void:
	_cues.stream = CUES[id]
	_cues.play()


func _exit_tree() -> void:
	if _crossfade:
		_crossfade.kill()
	_cues.stop()
	_cues.stream = null
	for player in _players:
		player.stop()
		player.stream = null
