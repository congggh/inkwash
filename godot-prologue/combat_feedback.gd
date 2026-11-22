extends Node2D

const STAIN_LIMIT := 16
const DOMAIN_COST := 60
const DOMAIN_TIME := 3.0
const DOMAIN_RADIUS := 1700.0

var energy := 0
var origin := Vector2.ZERO
var radius := 0.0
var domain_left := 0.0
var shake := 0.0
var hurt := 0.0
var stains := PackedVector3Array()
var droplets: Array[Dictionary] = []
var _sounds: Dictionary[StringName, AudioStreamWAV] = {}
var _voices: Array[AudioStreamPlayer] = []
var _voice_index := 0


func _ready() -> void:
	for index in range(5):
		var voice := AudioStreamPlayer.new()
		add_child(voice)
		_voices.append(voice)
	_sounds[&"swing"] = _sound(0.22, 245.0, 0.64, 8.0)
	_sounds[&"strike"] = _sound(0.14, 122.0, 0.55, 22.0)
	_sounds[&"hurt"] = _sound(0.30, 70.0, 0.28, 12.0)
	_sounds[&"domain"] = _sound(0.85, 145.0, 0.10, 3.7)
	reset()


func reset() -> void:
	energy = 0
	radius = 0.0
	domain_left = 0.0
	shake = 0.0
	hurt = 0.0
	stains = PackedVector3Array()
	stains.resize(STAIN_LIMIT)
	droplets.clear()
	for voice in _voices:
		voice.stop()
	queue_redraw()


func cue(sound: StringName, strength: float) -> void:
	shake = maxf(shake, strength)
	var voice := _voices[_voice_index]
	_voice_index = (_voice_index + 1) % _voices.size()
	voice.stream = _sounds[sound]
	voice.volume_db = -10.0 if sound == &"swing" else -6.0
	voice.play()


func receive_hit() -> void:
	hurt = 0.28
	cue(&"hurt", 12.0)


func land_hit(at_x: float, floor_y: float, facing: float, charge: int) -> void:
	energy = mini(100, energy + charge)
	cue(&"strike", 4.0)
	for index in range(5):
		if droplets.size() >= 60:
			droplets.pop_front()
		var start := Vector2(at_x, floor_y - 60.0 - randf_range(0.0, 18.0))
		droplets.append({"point": start, "velocity": Vector2(randf_range(26.0, 245.0) * facing, -randf_range(70.0, 260.0)), "floor": floor_y, "size": randf_range(14.0, 34.0)})


func expand(at: Vector2) -> bool:
	if energy < DOMAIN_COST:
		return false
	energy -= DOMAIN_COST
	origin = at
	radius = 1.0
	domain_left = DOMAIN_TIME
	cue(&"domain", 7.0)
	return true


func _process(delta: float) -> void:
	hurt = maxf(0.0, hurt - delta)
	shake = move_toward(shake, 0.0, 38.0 * delta)
	domain_left = maxf(0.0, domain_left - delta)
	var target := DOMAIN_RADIUS if domain_left > 0.0 else 0.0
	radius = move_toward(radius, target, (1500.0 if target > 0.0 else 1050.0) * delta)
	for index in range(droplets.size() - 1, -1, -1):
		var drop := droplets[index]
		var velocity: Vector2 = drop["velocity"]
		velocity.y += 990.0 * delta
		var point: Vector2 = drop["point"] + velocity * delta
		if point.y >= float(drop["floor"]):
			stains.remove_at(0)
			stains.append(Vector3(point.x, float(drop["floor"]), drop["size"]))
			droplets.remove_at(index)
		else:
			drop["point"] = point
			drop["velocity"] = velocity
	queue_redraw()


func _draw() -> void:
	for drop in droplets:
		draw_circle(drop["point"], float(drop["size"]) * 0.15, Color("#af322a"))


func _sound(duration: float, pitch: float, grit: float, decay: float) -> AudioStreamWAV:
	var rate := 22050
	var count := int(duration * rate)
	var bytes := PackedByteArray()
	bytes.resize(count * 2)
	var rng := RandomNumberGenerator.new()
	rng.seed = 716
	var phase := 0.0
	var noise := 0.0
	for index in range(count):
		var time := float(index) / rate
		phase += TAU * pitch * (0.65 + 0.55 * exp(-time * 8.0)) / rate
		noise = lerpf(noise, rng.randf_range(-1.0, 1.0), 0.55)
		var edge := minf(1.0, minf(time * 500.0, (duration - time) * 180.0))
		var tone := sin(phase) * 0.74 + sin(phase * 1.51) * 0.26
		bytes.encode_s16(index * 2, int(23000.0 * edge * exp(-time * decay) * lerpf(tone, noise, grit)))
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = rate
	stream.data = bytes
	return stream
