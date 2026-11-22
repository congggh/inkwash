extends Node2D

const DROP_MARGIN := 65.0
const FALL_SLOPE := 0.14
const SPLASH_TIME := 0.17

class Drop:
	var position := Vector2.ZERO
	var speed := 0.0
	var length := 0.0
	var strength := 0.0
	var hits_path := false
	var splash_left := 0.0

@export var foreground := false

@onready var scene := get_parent()
@onready var camera: Camera2D = scene.get_node("Camera")

var drops: Array[Drop] = []
var rng := RandomNumberGenerator.new()


func _process(delta: float) -> void:
	if not visible:
		return
	var span := get_viewport_rect().size.x / camera.zoom.x
	var left := camera.get_screen_center_position().x - span * 0.5 - DROP_MARGIN
	var right := left + span + DROP_MARGIN * 2.0
	var count := clampi(roundi(span * (0.032 if foreground else 0.115)), 1, 640)
	drops.resize(count)
	for index in range(count):
		var drop := drops[index]
		if drop == null:
			drop = Drop.new()
			drops[index] = drop
			_reset_drop(drop, left, right, true)
		if drop.position.x < left or drop.position.x > right:
			_reset_drop(drop, left, right, true)
		if drop.splash_left > 0.0:
			drop.splash_left -= delta
			if drop.splash_left <= 0.0:
				_reset_drop(drop, left, right, false)
			continue

		drop.position += Vector2(-FALL_SLOPE, 1.0) * drop.speed * delta
		var limit := _fall_limit(drop)
		if drop.position.y >= limit:
			if drop.hits_path:
				drop.position.y = limit
				drop.splash_left = SPLASH_TIME
			else:
				_reset_drop(drop, left, right, false)
	queue_redraw()


func _fall_limit(drop: Drop) -> float:
	return scene._floor_at(drop.position.x) + 11.0 if drop.hits_path else 865.0


func _reset_drop(drop: Drop, left: float, right: float, fill_view: bool) -> void:
	drop.position.x = rng.randf_range(left, right)
	drop.speed = rng.randf_range(940.0, 1330.0) if foreground else rng.randf_range(540.0, 910.0)
	drop.length = rng.randf_range(18.0, 42.0) if foreground else rng.randf_range(9.0, 26.0)
	drop.strength = rng.randf_range(0.29, 0.53) if foreground else rng.randf_range(0.15, 0.37)
	drop.hits_path = foreground and rng.randf() < 0.64
	drop.splash_left = 0.0
	drop.position.y = rng.randf_range(-42.0, _fall_limit(drop)) if fill_view else rng.randf_range(-235.0, -42.0)


func _draw() -> void:
	for drop in drops:
		var head := drop.position
		var strength: float = drop.strength * scene.rain_strength_at(head.x)
		if strength < 0.01:
			continue
		if drop.splash_left > 0.0:
			var progress := 1.0 - drop.splash_left / SPLASH_TIME
			var shine := Color(1.0, 0.37, 0.27, strength * (1.0 - progress))
			var radius := 2.0 + progress * 9.0
			draw_line(head + Vector2(-radius, 0.0), head + Vector2(-radius * 0.65, -2.5), shine, 1.0, true)
			draw_line(head + Vector2(radius * 0.45, -2.5), head + Vector2(radius, 0.0), shine, 1.0, true)
			continue

		var tail := head + Vector2(FALL_SLOPE, -1.0) * drop.length
		var middle := tail.lerp(head, 0.55)
		var hue := Color(0.98, 0.20, 0.17) if foreground else Color(0.92, 0.22, 0.19)
		draw_line(tail, middle, Color(hue, strength * 0.37), 1.0, true)
		draw_line(middle, head, Color(hue, strength), 1.55 if foreground else 1.05, true)
