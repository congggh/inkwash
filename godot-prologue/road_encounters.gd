extends Node2D

signal enemy_windup
signal player_hit(source_x: float, amount: int)
signal enemy_hurt(at_x: float, facing: float, charge: int)

const EnemyVisual = preload("res://art/characters/ink_void_enemies/visual_driver.gd")
const ART := "res://art/characters/ink_void_enemies/"
const MONUMENTS := [
	[3240.0, 3420.0, 165.0, 3],
	[11435.0, 11645.0, 192.0, 4],
]
const ROSTER := [
	["river_laborer", "巡水工偶", 2500.0, &"idle", &"mud_walk", &"hook_sweep", 3],
	["wave_magistrate", "伏波画督", 4600.0, &"idle", &"marionette_walk", &"screen_wave_screen_peel", 4],
	["string_inquisitor", "司弦刑官", 6950.0, &"idle", &"ghost_step", &"string_strike_armor_break", 4],
	["pallor_deacon", "去色司祝", 12050.0, &"idle", &"ceremonial_glide", &"frost_sweep", 3],
	["balance_praetor", "平规衡司", 16720.0, &"idle", &"scales_float", &"scales_spill_balance_break", 4],
	["mo_zhu", "墨竹", 21650.0, &"spear_stride", &"wave_surf", &"spear_thrust_ink_wall", 6],
	["mo_gu", "墨骨", 22800.0, &"wing_hover", &"wing_glide", &"iron_whip_dive", 7],
	["gu_kuangmo", "顾狂墨", 24000.0, &"divine_hover", &"cursive_dash", &"ruler_array_transformation", 8],
]
const INK := Color("#2b2326")
const PAPER := Color("#e7d5b6")
const WARN := Color("#e97559")

class Opponent:
	var actor: EnemyVisual
	var x := 0.0
	var hp := 0
	var windup := 0.0
	var recovery := 0.0
	var facing := -1.0

var _actors: Array[Opponent] = []
var _floor: Callable
var _current_x := 0.0
var _stone_hp := PackedInt32Array()
var _stone_flash := PackedFloat32Array()


func setup(floor_query: Callable) -> void:
	_floor = floor_query
	for entry in ROSTER:
		var packed := load(ART + entry[0] + "/visual.tscn") as PackedScene
		var opponent := Opponent.new()
		opponent.actor = packed.instantiate() as EnemyVisual
		opponent.actor.scale = Vector2.ONE * (0.56 if int(entry[6]) >= 6 else 0.46)
		add_child(opponent.actor)
		_actors.append(opponent)
	reset()


func reset() -> void:
	_stone_hp.resize(MONUMENTS.size())
	_stone_flash.resize(MONUMENTS.size())
	for index in range(MONUMENTS.size()):
		_stone_hp[index] = int(MONUMENTS[index][3])
		_stone_flash[index] = 0.0
	for i in range(_actors.size()):
		var foe := _actors[i]
		foe.x = float(ROSTER[i][2])
		foe.hp = int(ROSTER[i][6])
		foe.windup = 0.0
		foe.recovery = 0.0
		foe.facing = -1.0
		foe.actor.hide()
	queue_redraw()


func ground_height(x: float) -> float:
	for index in range(MONUMENTS.size()):
		var stone: Array = MONUMENTS[index]
		if _stone_hp[index] > 0 and x > float(stone[0]) and x < float(stone[1]):
			return float(stone[2])
	return 0.0


func resolve_motion(previous: float, target: float, height: float) -> float:
	var resolved := target
	for index in range(MONUMENTS.size()):
		var stone: Array = MONUMENTS[index]
		if _stone_hp[index] <= 0 or height >= float(stone[2]):
			continue
		var left := float(stone[0])
		var right := float(stone[1])
		if previous <= left and resolved > left:
			resolved = left
		elif previous >= right and resolved < right:
			resolved = right
	return resolved


func right_limit(fallback: float) -> float:
	for i in range(5, _actors.size()):
		if _actors[i].hp > 0:
			return minf(fallback, float(ROSTER[i][2]) + 285.0)
	return fallback


func slash(x: float, facing: float) -> bool:
	for index in range(MONUMENTS.size()):
		if _stone_hp[index] <= 0:
			continue
		var stone: Array = MONUMENTS[index]
		var near_edge := float(stone[0] if facing > 0.0 else stone[1])
		var reach := (near_edge - x) * facing
		if reach >= -2.0 and reach <= 145.0:
			_stone_hp[index] -= 1
			_stone_flash[index] = 0.34 if _stone_hp[index] == 0 else 0.13
			return true
	for foe in _actors:
		var distance := (foe.x - x) * facing
		if foe.hp <= 0 or distance < -20.0 or distance > 155.0:
			continue
		foe.hp -= 1
		enemy_hurt.emit(foe.x, facing, 20)
		if foe.hp == 0:
			foe.actor.hide()
		elif foe.windup <= 0.0:
			foe.recovery = maxf(foe.recovery, 0.12)
	return false


func advance(delta: float, x: float, height: float, guarded: bool) -> void:
	_current_x = x
	for index in range(_stone_flash.size()):
		_stone_flash[index] = maxf(0.0, _stone_flash[index] - delta)
	for i in range(_actors.size()):
		var foe := _actors[i]
		var near := absf(x - foe.x) < 960.0 and foe.hp > 0
		foe.actor.visible = near
		if not near:
			continue
		var entry: Array = ROSTER[i]
		var boss := int(entry[6]) >= 6
		var reach := 130.0 if boss else 106.0
		var offset := x - foe.x
		var clip: StringName = entry[3]
		foe.recovery = maxf(0.0, foe.recovery - delta)
		if foe.windup > 0.0:
			clip = entry[5]
			foe.windup = maxf(0.0, foe.windup - delta)
			if foe.windup == 0.0:
				foe.recovery = 0.86
				if absf(offset) <= reach and offset * foe.facing >= -20.0 and height < 64.0 and not guarded:
					player_hit.emit(foe.x, 18 if boss else 12)
		elif absf(offset) < 475.0 and foe.recovery <= 0.0:
			if not is_zero_approx(offset):
				foe.facing = signf(offset)
			if absf(offset) > reach - 30.0:
				var goal := clampf(x - foe.facing * (reach - 32.0), float(entry[2]) - 260.0, float(entry[2]) + 220.0)
				var movement := move_toward(foe.x, goal, delta * (195.0 if boss else 155.0))
				if not is_equal_approx(movement, foe.x):
					clip = entry[4]
				foe.x = resolve_motion(foe.x, movement, 0.0)
			else:
				foe.windup = 0.65 if boss else 0.53
				clip = entry[5]
				enemy_windup.emit()
		foe.actor.position = Vector2(foe.x, float(_floor.call(foe.x)))
		foe.actor.face(foe.facing)
		foe.actor.play_pose(clip)
	queue_redraw()


func _draw() -> void:
	if not _floor.is_valid():
		return
	for index in range(_stone_hp.size()):
		_draw_monument(index)
	for i in range(_actors.size()):
		var foe := _actors[i]
		if not foe.actor.visible:
			continue
		var foot := foe.actor.position
		if foe.windup > 0.0:
			var finish := foot + Vector2(foe.facing * (130.0 if i >= 5 else 106.0), 0.0)
			draw_line(foot, finish, WARN, 6.0, true)
		var y := -190.0 if i >= 5 else -150.0
		var health_rect := Rect2(foot + Vector2(-48.0, y + 18.0), Vector2(96.0, 5.0))
		draw_rect(health_rect, INK)
		health_rect.size.x *= float(foe.hp) / float(ROSTER[i][6])
		draw_rect(health_rect, WARN)
		_tag(ROSTER[i][1], foot + Vector2(0.0, y))


func _draw_monument(index: int) -> void:
	var stone: Array = MONUMENTS[index]
	var left := float(stone[0])
	var width := float(stone[1]) - left
	var height := float(stone[2])
	var base := float(_floor.call(left))
	var top := Vector2(left, base - height)
	var foot := Vector2(left + width * 0.5, base)
	if _stone_hp[index] > 0:
		var face := PAPER.darkened(0.31) if _stone_flash[index] > 0.0 else Color("#4b3e3a")
		draw_colored_polygon(PackedVector2Array([
			top + Vector2(0, 21), top + Vector2(width * 0.20, 0),
			top + Vector2(width * 0.72, 10), top + Vector2(width, 48),
			top + Vector2(width, height), top + Vector2(0, height),
		]), face)
		draw_rect(Rect2(top + Vector2(15, height - 22.0), Vector2(width - 30.0, 17.0)), INK)
		var cracks := int(stone[3]) - _stone_hp[index]
		for crack in range(cracks + 1):
			var start := top + Vector2(width * (0.2 + 0.19 * crack), 18.0 + 11.0 * crack)
			draw_polyline(PackedVector2Array([start, start + Vector2(21, 41), start + Vector2(-3, 58), start + Vector2(33, height * 0.72)]), PAPER.darkened(0.42), 3.0, true)
		if absf(_current_x - foot.x) < 265.0:
			_tag("断碑 · J 击碎  %d/%d" % [_stone_hp[index], int(stone[3])], top + Vector2(width * 0.5, -14.0))
	elif _stone_flash[index] > 0.0:
		var alpha := _stone_flash[index] / 0.34
		for shard in range(9):
			var angle := -PI * float(shard) / 8.0
			var point := foot + Vector2(0, -55) + Vector2.from_angle(angle) * (1.0 - alpha) * 134.0
			draw_colored_polygon(PackedVector2Array([point, point + Vector2(14, 6), point + Vector2(5, 17)]), Color(PAPER, alpha))


func _tag(text: String, position: Vector2) -> void:
	var font := ThemeDB.fallback_font
	var width := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, 19).x
	var baseline := position - Vector2(width * 0.5, 0)
	draw_string_outline(font, baseline, text, HORIZONTAL_ALIGNMENT_LEFT, -1, 19, 6, INK)
	draw_string(font, baseline, text, HORIZONTAL_ALIGNMENT_LEFT, -1, 19, PAPER)
