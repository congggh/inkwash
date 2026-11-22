extends Node2D

signal parried
signal enemy_windup
signal player_hurt(source_x: float)
signal enemy_hurt(at_x: float, facing: float, charge: int)

const EnemyVisual = preload("res://art/characters/ink_void_enemies/visual_driver.gd")
const PATROL_ART := preload("res://art/characters/ink_void_enemies/blind_patrol/visual.tscn")
const WARDEN_ART := preload("res://art/characters/ink_void_enemies/peak_warden/visual.tscn")

const MAX_HEALTH := 100
const START_X := 260.0
const END_X := 1580.0
const DASH_SPEED := 2000.0
const DASH_DURATION := 0.18
const DASH_SAFE_TIME := 0.14
const GRIND_SPEED := 3125.0
const ENDPOINT_RANGE := 45.0
const FINISH_RANGE := 220.0
const COUNTER_RANGE := 100.0
const PARRY_WINDOW := 0.16
const PARRY_FREEZE := 0.26
const MINT := Color("#b5ffe9")
const RED := Color("#ff9174")
const PAPER := Color("#f9e5cc")
const INK := Color("#241e20")
const RIFT_ATLAS := preload("res://art/characters/mohen_sop4/atlases/rift_decal.png")
const RIFT_FRAME_SIZE := Vector2(300.0, 300.0)
const EXECUTION_FADE := 0.24

var active := false
var round_index := 0
var health := MAX_HEALTH
var cleared := false
var hint := ""
var dash_left := 0.0
var dash_cooldown := 0.0
var grinding := false
var rift_start := 0.0
var rift_end := 0.0
var rift_remaining := 0.0
var rift_spent := false
var enemy_x := 0.0
var exposed := false
var counter_left := 0.0
var shield_facing := -1.0
var rift_finishes := 0
var parry_left := 0.0
var parry_freeze_left := 0.0
var _dash_direction := 1.0
var _destination := 0.0
var _enemy_hits := 0
var _recovery_left := 0.0
var _rift_age := 0.0
var _executed_x := 0.0
var _execution_left := 0.0
var _patrol: EnemyVisual
var _warden: EnemyVisual


func _ready() -> void:
	_patrol = PATROL_ART.instantiate() as EnemyVisual
	_warden = WARDEN_ART.instantiate() as EnemyVisual
	for visual in [_patrol, _warden]:
		visual.hide()
		visual.scale = Vector2.ONE * 0.48
		add_child(visual)


func open(floor_y: float) -> void:
	active = true
	position.y = floor_y
	show()


func reset() -> void:
	round_index = 0
	health = MAX_HEALTH
	cleared = false
	dash_left = 0.0
	dash_cooldown = 0.0
	grinding = false
	rift_remaining = 0.0
	_rift_age = 0.0
	_execution_left = 0.0
	rift_spent = false
	rift_finishes = 0
	parry_left = 0.0
	parry_freeze_left = 0.0
	_spawn_enemy(445.0)
	hint = "按 Shift 冲过巡卒，从裂隙终点按 E 钻回来。"


func _spawn_enemy(at_x: float) -> void:
	enemy_x = at_x
	exposed = false
	counter_left = 0.0
	shield_facing = -1.0
	_recovery_left = 0.0
	_enemy_hits = 0
	_sync_enemy_art(at_x - 1.0)
	queue_redraw()


func is_rushing() -> bool:
	return dash_left > 0.0 or grinding


func is_over() -> bool:
	return cleared or health <= 0


func dash(from_x: float, direction: float) -> bool:
	if is_rushing() or is_over():
		return false
	if dash_cooldown > 0.0:
		hint = "冲刺冷却中。处决后会马上刷新。"
		return false
	_dash_direction = direction
	dash_left = DASH_DURATION
	rift_start = from_x
	rift_end = from_x
	rift_remaining = 5.0
	_rift_age = 0.0
	rift_spent = false
	hint = "裂隙已生成。站在任一发光端点按 E。"
	return true


func cut_rift(from_x: float, direction: float) -> void:
	rift_start = from_x
	rift_end = clampf(from_x + direction * 280.0, 80.0, END_X)
	rift_remaining = 5.0
	_rift_age = 0.0
	rift_spent = false
	hint = "第三刀划开了裂隙。从发光端点按 E 可以钻进去。"
	queue_redraw()


func grind(from_x: float) -> bool:
	if is_rushing() or is_over():
		return false
	if rift_remaining <= 0.0 or rift_spent or absf(rift_end - rift_start) < 10.0:
		hint = "没有可钻的裂隙。先按 Shift 造缝。"
		return false
	var to_start := absf(from_x - rift_start)
	var to_end := absf(from_x - rift_end)
	if minf(to_start, to_end) > ENDPOINT_RANGE:
		hint = "走到裂隙的发光端点，再按 E。"
		return false
	_destination = rift_end if to_start <= to_end else rift_start
	grinding = true
	hint = "沿裂隙穿过敌人可破甲。"
	return true


func advance(delta: float, at_x: float, in_air: bool) -> float:
	if _execution_left > 0.0:
		_execution_left = maxf(0.0, _execution_left - delta)
		queue_redraw()
	if cleared:
		return at_x
	if parry_freeze_left > 0.0:
		parry_freeze_left = maxf(0.0, parry_freeze_left - delta)
		_sync_enemy_art(at_x)
		queue_redraw()
		return at_x
	if rift_remaining > 0.0:
		_rift_age += delta
	dash_cooldown = maxf(dash_cooldown - delta, 0.0)
	rift_remaining = maxf(rift_remaining - delta, 0.0)
	var safe := grinding or dash_left > DASH_DURATION - DASH_SAFE_TIME
	if dash_left > 0.0:
		at_x = clampf(at_x + _dash_direction * DASH_SPEED * minf(delta, dash_left), 80.0, END_X)
		rift_end = at_x
		dash_left = maxf(dash_left - delta, 0.0)
		if dash_left == 0.0:
			dash_cooldown = 1.1
	elif grinding:
		var previous := at_x
		at_x = move_toward(at_x, _destination, GRIND_SPEED * delta)
		if enemy_x >= minf(previous, at_x) and enemy_x <= maxf(previous, at_x) and not exposed:
			enemy_hurt.emit(enemy_x, signf(at_x - previous), 30)
			exposed = true
			counter_left = 0.0
			hint = "钻缝命中，敌人已破甲。按 F 处决并刷新冲刺。"
		if is_equal_approx(at_x, _destination):
			grinding = false
			rift_spent = true
			rift_remaining = 1.25

	if not exposed:
		_update_shield(delta, at_x, safe or in_air)
	var was_parrying := parry_left > 0.0
	parry_left = maxf(0.0, parry_left - delta)
	if was_parrying and parry_left == 0.0 and not exposed:
		hint = "招架窗口已过。等盾兵的红色反击落下前再按 F。"
	_sync_enemy_art(at_x)
	queue_redraw()
	return at_x


func try_parry(at_x: float) -> bool:
	if round_index != 1 or exposed or is_rushing() or is_over() or absf(at_x - enemy_x) > 145.0:
		return false
	if parry_left > 0.0:
		return true
	parry_left = PARRY_WINDOW
	hint = "招架中。刀锋落下的瞬间才能撕甲。"
	return true


var pursuing := false


func _update_shield(delta: float, at_x: float, avoid_counter: bool) -> void:
	pursuing = false
	var offset := at_x - enemy_x
	if _recovery_left > 0.0:
		_recovery_left = maxf(_recovery_left - delta, 0.0)
		return
	if counter_left <= 0.0:
		if not is_zero_approx(offset):
			shield_facing = signf(offset)
		if absf(offset) > 90.0 and absf(offset) < 395.0 and not is_rushing():
			var goal := clampf(at_x - shield_facing * 80.0, 190.0, END_X - 40.0)
			var next := move_toward(enemy_x, goal, delta * (155.0 if round_index == 0 else 124.0))
			pursuing = not is_equal_approx(next, enemy_x)
			enemy_x = next
		elif absf(offset) <= 90.0:
			counter_left = 0.57 if round_index == 0 else 0.48
			enemy_windup.emit()
		return
	counter_left = maxf(counter_left - delta, 0.0)
	if counter_left > 0.0:
		return
	_recovery_left = 0.80
	if absf(offset) > COUNTER_RANGE or offset * shield_facing < 0.0 or avoid_counter:
		hint = "敌人攻击落空。趁收招时按 J。"
		return
	if parry_left > 0.0:
		exposed = true
		parry_left = 0.0
		parry_freeze_left = PARRY_FREEZE
		hint = "弹反成功，盾甲已撕开。按 F 处决。"
		enemy_hurt.emit(enemy_x, signf(enemy_x - at_x), 25)
		parried.emit()
		return
	health = maxi(0, health - (12 if round_index == 0 else 15))
	player_hurt.emit(enemy_x)
	hint = "墨痕受伤。看到出招预警时退开、跳起或弹反。"
	if health == 0:
		hint = "试炼失败。按 R 从序章开场重来。"


func attack(from_x: float, direction: float) -> void:
	var target_distance := enemy_x - from_x
	if is_over() or absf(target_distance) > 115.0 or target_distance * direction < 0.0:
		return
	var shield_side := (from_x - enemy_x) * shield_facing >= 0.0
	if round_index == 1 and not exposed and _recovery_left <= 0.0 and shield_side:
		if counter_left <= 0.0:
			counter_left = 0.48
			enemy_windup.emit()
		hint = "正面被格挡。反击将落下时按 F 弹反，也可退开或钻缝。"
		return
	enemy_hurt.emit(enemy_x, direction, 30)
	_enemy_hits += 1
	if _enemy_hits >= 3:
		_complete_round()
	else:
		hint = "斩击命中。还需 %d 刀。" % (3 - _enemy_hits)


func finish(from_x: float) -> float:
	if is_rushing() or is_over() or parry_freeze_left > 0.0:
		return from_x
	if not exposed or absf(from_x - enemy_x) > FINISH_RANGE:
		hint = "靠近已破甲的敌人，再按 F。"
		return from_x
	enemy_hurt.emit(enemy_x, signf(enemy_x - from_x), 30)
	rift_finishes += 1
	_executed_x = enemy_x
	_execution_left = EXECUTION_FADE
	dash_cooldown = 0.0
	var strike_x := enemy_x + (-55.0 if from_x <= enemy_x else 55.0)
	_complete_round()
	return strike_x


func _complete_round() -> void:
	rift_remaining = 0.0
	if round_index == 0:
		round_index = 1
		_spawn_enemy(1060.0)
		hint = "巡卒已击败。向右找盾兵，试试刚才学会的打法。"
	else:
		cleared = true
		hint = "前路已清。继续往右走。"
		_sync_enemy_art(enemy_x)
	queue_redraw()


func status_text() -> String:
	return "%s    冲刺 %s" % [
		"盾兵" if round_index == 1 else "巡卒",
		"就绪" if dash_cooldown <= 0.0 else "%.1f 秒" % dash_cooldown,
	]


func _draw() -> void:
	if not active:
		return
	if rift_remaining > 0.0:
		_draw_rift()
	if _execution_left > 0.0:
		_draw_execution_fragments()
	if cleared:
		return
	if parry_freeze_left > 0.0:
		draw_arc(Vector2(enemy_x, -70.0), 84.0, 0.0, TAU, 40, Color(MINT, parry_freeze_left / PARRY_FREEZE), 5.0, true)
	if counter_left > 0.0:
		var left := enemy_x - COUNTER_RANGE if shield_facing < 0.0 else enemy_x
		draw_rect(Rect2(left, -4, COUNTER_RANGE, 12), PAPER if counter_left <= PARRY_WINDOW else RED)
	var caption := "巡卒"
	if exposed:
		caption = "已破甲 · F 处决"
	elif round_index == 1:
		caption = "收盾 · J 可反击" if _recovery_left > 0.0 else "盾兵 · 格挡"
	var tag_height := -212.0 if round_index == 1 else -179.0
	var tag := Rect2(enemy_x - 89.0, tag_height, 178.0, 35.0)
	draw_rect(tag, INK)
	draw_string(ThemeDB.fallback_font, tag.position + Vector2(0, 25), caption, HORIZONTAL_ALIGNMENT_CENTER, tag.size.x, 21, PAPER)

func _sync_enemy_art(player_x: float) -> void:
	_patrol.visible = not cleared and round_index == 0
	_warden.visible = not cleared and round_index == 1
	if cleared:
		return
	var visual := _patrol if round_index == 0 else _warden
	visual.position.x = enemy_x
	visual.face(signf(player_x - enemy_x) if round_index == 0 and counter_left <= 0.0 else shield_facing)
	visual.modulate = Color(0.76, 1.0, 0.92) if exposed else Color.WHITE
	if exposed:
		if round_index == 0:
			visual.play_pose(&"ruler_cleave_armor_peel", 0.50)
		else:
			visual.play_pose(&"shield_charge_armor_peel", 0.40)
	elif counter_left > 0.0:
		visual.play_pose(&"ruler_cleave_armor_peel" if round_index == 0 else &"shield_charge_armor_peel")
	elif pursuing:
		visual.play_pose(&"rush" if round_index == 0 else &"shield_step")
	else:
		visual.play_pose(&"idle")


func _draw_rift() -> void:
	var reveal := clampf(_rift_age / 0.12, 0.0, 1.0)
	var tip := lerpf(rift_start, rift_end, reveal)
	var length := absf(tip - rift_start)
	if length < 1.0:
		return
	var frame := 0
	for threshold in [0.033, 0.083, 0.150]:
		if _rift_age >= threshold:
			frame += 1
	var opacity := clampf(rift_remaining * 2.5, 0.0, 1.0)
	if rift_spent:
		opacity *= 0.55
	var region := Rect2(Vector2(frame * RIFT_FRAME_SIZE.x, 0.0), RIFT_FRAME_SIZE)
	var mark := Rect2(minf(tip, rift_start), -35.0, length, 78.0)
	var shape := PackedVector2Array([
		Vector2(rift_start, 4.0), Vector2(lerpf(rift_start, tip, 0.19), 2.0),
		Vector2(lerpf(rift_start, tip, 0.34), 8.0), Vector2(lerpf(rift_start, tip, 0.60), 1.0),
		Vector2(lerpf(rift_start, tip, 0.80), 6.0), Vector2(tip, 4.0),
	])
	draw_polyline(shape, Color(0.08, 0.13, 0.13, opacity * 0.9), 7.0, true)
	draw_polyline(shape, Color(0.76, 0.99, 0.92, opacity * 0.82), 2.6, true)
	draw_texture_rect_region(RIFT_ATLAS, mark, region, Color(0.86, 1.0, 0.97, opacity))
	if rift_spent:
		return
	var marker := Color(MINT, opacity)
	var pulse := 6.0 + 1.2 * sin(_rift_age * 8.0)
	draw_arc(Vector2(rift_start, 4.0), pulse, 0.0, TAU, 18, marker, 1.8, true)
	draw_arc(Vector2(tip, 4.0), pulse, 0.0, TAU, 18, marker, 1.8, true)


func _draw_execution_fragments() -> void:
	var progress := 1.0 - _execution_left / EXECUTION_FADE
	var shade := Color(PAPER, 1.0 - progress)
	for index in range(9):
		var angle := index * 2.4
		var spread := Vector2(cos(angle) * 48.0, sin(angle) * 31.0 - 43.0)
		var centre := Vector2(_executed_x, -65.0) + spread * progress
		var edge := Vector2.from_angle(angle + progress * 4.0) * 8.0
		draw_colored_polygon(PackedVector2Array([
			centre - edge, centre + edge.orthogonal() * 0.45, centre + edge,
		]), shade)
