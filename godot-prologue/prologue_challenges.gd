extends Node2D

signal boss_track_requested(inner: bool)
signal player_hit(source_x: float)
signal enemy_windup
signal enemy_hurt(at_x: float, facing: float, charge: int)

const EnemyVisual = preload("res://art/characters/ink_void_enemies/visual_driver.gd")
const STELE_ART := preload("res://art/characters/ink_void_enemies/stele_shade/visual.tscn")
const BOSS_ART := preload("res://art/characters/ink_void_enemies/mo_mei/visual.tscn")

enum BossPhase { ARMORED, STAGGERED, SCROLL, EXECUTE, FINISHING, CLEARED }

const GAP_START := 9950.0
const GAP_END := 10820.0
const BARREL_X := 10380.0
const BARREL_HEIGHT := 48.0
const BARREL_CONTACT_HALF := 96.0
const TAKEOFF_ZONE_WIDTH := 185.0
const FOLD_CENTRE := 14170.0
const FOLD_GATE := 14570.0
const BOSS_X := 20050.0
const BOSS_GATE := 20280.0
const SCROLL_STROKES := 7
const PAPER := Color("#f4e1c4")
const MINT := Color("#b5ffe9")
const GOLD := Color("#efbd76")
const RED := Color("#ff937a")
const INK := Color("#221d24")

var active := false
var gap_crossed := false
var pogo_hits := 0
var fold_targets: Array[float] = []
var fold_centre := 0.0
var fold_left := 0.0
var fold_cooldown := 0.0
var last_slash_hits := 0
var _mob_attack := 0.0
var _mob_recovery := 0.0
var _mob_attacker: EnemyVisual
var _mob_target_x := 0.0
var boss_x := BOSS_X
var boss_moving := false
var boss_phase := BossPhase.ARMORED
var boss_armor := 2
var boss_strokes := 0
var boss_left := 0.0
var boss_counter := 0.0
var boss_recovery := 0.0
var hint := ""
var _notice_left := 0.0
var _stroke_interval := 0.0
var _barrel_flash := 0.0
var _floor_at: Callable
var _stele_visuals: Array[EnemyVisual] = []
var _remaining_stele: Array[EnemyVisual] = []
var _boss_visual: EnemyVisual


func setup(floor_query: Callable) -> void:
	_floor_at = floor_query
	active = true
	for index in range(3):
		var actor := STELE_ART.instantiate() as EnemyVisual
		actor.scale = Vector2.ONE * 0.47
		add_child(actor)
		_stele_visuals.append(actor)
	_boss_visual = BOSS_ART.instantiate() as EnemyVisual
	_boss_visual.scale = Vector2.ONE * 0.52
	add_child(_boss_visual)
	reset()
	show()


func reset() -> void:
	gap_crossed = false
	pogo_hits = 0
	fold_targets.assign([FOLD_CENTRE - 170.0, FOLD_CENTRE + 95.0, FOLD_CENTRE + 280.0])
	_remaining_stele.assign(_stele_visuals)
	fold_centre = 0.0
	fold_left = 0.0
	fold_cooldown = 0.0
	last_slash_hits = 0
	_mob_attack = 0.0
	_mob_recovery = 0.0
	_mob_attacker = null
	boss_x = BOSS_X
	boss_moving = false
	boss_phase = BossPhase.ARMORED
	boss_armor = 2
	boss_strokes = 0
	boss_left = 0.0
	boss_counter = 0.0
	boss_recovery = 0.0
	_notice_left = 0.0
	_stroke_interval = 0.0
	_barrel_flash = 0.0
	_sync_art(0.0)
	queue_redraw()


func is_over_gap(at_x: float) -> bool:
	return at_x > GAP_START and at_x < GAP_END


func right_limit(course_end: float) -> float:
	if not fold_targets.is_empty():
		return FOLD_GATE
	return BOSS_GATE if boss_phase != BossPhase.CLEARED else course_end


func on_fall() -> float:
	_notice("已回到岸边。站在发光区按 K，空格弹射，到墨桶上方按 J。", 3.2)
	return GAP_END + 90.0 if gap_crossed else GAP_START - 155.0


func near_takeoff(at_x: float) -> bool:
	return at_x >= GAP_START - TAKEOFF_ZONE_WIDTH and at_x <= GAP_START + 100.0 		or at_x >= GAP_END - 100.0 and at_x <= GAP_END + TAKEOFF_ZONE_WIDTH


func barrel_below(previous: Vector2, current: Vector2) -> bool:
	if previous.y < BARREL_HEIGHT or current.y > BARREL_HEIGHT or previous.y <= current.y:
		return false
	var fraction := inverse_lerp(previous.y, current.y, BARREL_HEIGHT)
	return absf(lerpf(previous.x, current.x, fraction) - BARREL_X) <= BARREL_CONTACT_HALF


func pogo_contact(previous: Vector2, current: Vector2) -> bool:
	if not barrel_below(previous, current):
		return false
	pogo_hits += 1
	_barrel_flash = 0.38
	_notice("踩中墨桶，正在飞向对岸。", 2.7)
	return true


func fold(at_x: float, facing: float) -> bool:
	if fold_cooldown > 0.0:
		return false
	var centre := at_x + facing * 105.0
	var found := false
	for target in fold_targets:
		if absf(target - centre) <= 480.0:
			found = true
			break
	if not found:
		_notice("折纸范围内没有敌人。接近散阵后按 K。")
		return false
	fold_left = 0.24
	_mob_attack = 0.0
	_mob_attacker = null
	fold_cooldown = 1.25
	fold_centre = centre
	_notice("折纸正在聚敌，等它们合拢后按 J 横斩。")
	return true


func _in_slash(at_x: float, facing: float, target: float, reach: float) -> bool:
	var offset := (target - at_x) * facing
	return offset >= -18.0 and offset <= reach


func slash(at_x: float, facing: float) -> void:
	last_slash_hits = 0
	for index in range(fold_targets.size() - 1, -1, -1):
		if _in_slash(at_x, facing, fold_targets[index], 155.0):
			enemy_hurt.emit(fold_targets[index], facing, 20)
			if _remaining_stele[index] == _mob_attacker:
				_mob_attack = 0.0
				_mob_attacker = null
			fold_targets.remove_at(index)
			_remaining_stele.pop_at(index).hide()
			last_slash_hits += 1
	if last_slash_hits > 0:
		_notice("这一刀命中 %d 个敌人。%s" % [last_slash_hits,
			"散阵已清，继续向右。" if fold_targets.is_empty() else "剩余 %d 个。" % fold_targets.size()])
	if boss_phase != BossPhase.ARMORED or not _in_slash(at_x, facing, boss_x, 155.0):
		return
	enemy_hurt.emit(boss_x, facing, 30)
	boss_armor -= 1
	if boss_armor == 0:
		boss_phase = BossPhase.STAGGERED
		boss_left = 1.5
		boss_counter = 0.0
		_notice("墨梅失衡。现在按 I 展开领域掀卷。", 1.5)
	else:
		_notice("墨梅护甲剩余 %d。继续斩击。" % boss_armor)


func open_scroll(at_x: float, facing: float, domain_left: float) -> bool:
	if domain_left <= 0.0 or boss_phase != BossPhase.STAGGERED or not _in_slash(at_x, facing, boss_x, 170.0):
		return false
	boss_phase = BossPhase.SCROLL
	boss_strokes = 0
	boss_left = domain_left
	_stroke_interval = 0.0
	boss_track_requested.emit(true)
	_notice("白描里层已打开。贴近墨梅，连按七次 J。", 1.6)
	return true


func scroll_slash(at_x: float) -> bool:
	if boss_phase != BossPhase.SCROLL or _stroke_interval > 0.0 or absf(at_x - boss_x) > 190.0:
		return false
	enemy_hurt.emit(boss_x, signf(boss_x - at_x), 6)
	boss_strokes += 1
	_stroke_interval = 0.11
	if boss_strokes == SCROLL_STROKES:
		boss_phase = BossPhase.EXECUTE
		boss_left = 0.0
		_notice("七笔成字。靠近墨梅，按 F 完成终局处决。", 2.5)
	return true


func finish_boss(at_x: float) -> bool:
	if boss_phase != BossPhase.EXECUTE or absf(at_x - boss_x) > 155.0:
		return false
	boss_phase = BossPhase.FINISHING
	boss_left = 0.32
	_notice("墨梅 · 落卷", 1.2)
	return true


func advance(delta: float, at_x: float, height: float, guarded: bool) -> void:
	if at_x >= GAP_END and not gap_crossed and height >= 0.0:
		gap_crossed = true
		_notice("已到达对岸。继续向右，寻找散阵。")
	_notice_left = maxf(0.0, _notice_left - delta)
	_barrel_flash = maxf(0.0, _barrel_flash - delta)
	fold_cooldown = maxf(0.0, fold_cooldown - delta)
	if fold_left > 0.0:
		for index in range(fold_targets.size()):
			var target := fold_centre + (float(index) - float(fold_targets.size() - 1) * 0.5) * 36.0
			if absf(fold_targets[index] - fold_centre) <= 480.0:
				fold_targets[index] = move_toward(fold_targets[index], target, 2200.0 * delta)
		fold_left = maxf(0.0, fold_left - delta)
	_tick_mobs(delta, at_x, height, guarded)
	_tick_boss(delta, at_x, height, guarded)
	_sync_art(at_x)
	queue_redraw()


func _tick_mobs(delta: float, at_x: float, height: float, guarded: bool) -> void:
	_mob_recovery = maxf(0.0, _mob_recovery - delta)
	if fold_left > 0.0 or fold_targets.is_empty():
		return
	if _mob_attack > 0.0:
		_mob_attack = maxf(0.0, _mob_attack - delta)
		if _mob_attack == 0.0:
			_mob_recovery = 1.15
			if absf(at_x - _mob_target_x) <= 96.0 and height < 58.0 and not guarded:
				player_hit.emit(_mob_target_x)
			_mob_attacker = null
		return
	if _mob_recovery > 0.0:
		return
	for index in range(fold_targets.size()):
		var offset := at_x - fold_targets[index]
		if absf(offset) > 85.0 and absf(offset) < 260.0:
			fold_targets[index] = move_toward(fold_targets[index], at_x - signf(offset) * 82.0, delta * 93.0)
		if absf(offset) <= 85.0:
			_mob_target_x = fold_targets[index]
			_mob_attacker = _remaining_stele[index]
			_mob_attack = 0.63
			enemy_windup.emit()
			return


func _tick_boss(delta: float, at_x: float, height: float, guarded: bool) -> void:
	boss_moving = false
	_stroke_interval = maxf(0.0, _stroke_interval - delta)
	boss_left = maxf(0.0, boss_left - delta)
	match boss_phase:
		BossPhase.ARMORED:
			boss_recovery = maxf(0.0, boss_recovery - delta)
			if boss_counter > 0.0:
				boss_counter = maxf(0.0, boss_counter - delta)
				if boss_counter == 0.0:
					boss_recovery = 1.15
					if absf(at_x - boss_x) <= 95.0 and height < 58.0 and not guarded:
						player_hit.emit(boss_x)
			elif boss_recovery == 0.0 and absf(at_x - boss_x) < 485.0:
				var offset := at_x - boss_x
				if absf(offset) > 86.0:
					var goal := clampf(at_x - signf(offset) * 81.0, BOSS_X - 260.0, BOSS_X + 180.0)
					var next := move_toward(boss_x, goal, delta * 176.0)
					boss_moving = not is_equal_approx(next, boss_x)
					boss_x = next
				else:
					boss_counter = 0.65
					enemy_windup.emit()
		BossPhase.STAGGERED, BossPhase.SCROLL:
			if boss_left == 0.0:
				if boss_phase == BossPhase.SCROLL:
					boss_track_requested.emit(false)
				boss_phase = BossPhase.ARMORED
				boss_armor = 2
				boss_strokes = 0
				boss_recovery = 1.0
				_notice("时机已过，墨梅重新站稳。先用 J 打掉护甲。")
		BossPhase.FINISHING:
			if boss_left == 0.0:
				boss_phase = BossPhase.CLEARED
				boss_track_requested.emit(false)
				_notice("墨梅已落败。向右继续进入飞瀑段。", 3.0)


func _notice(message: String, duration := 1.8) -> void:
	hint = message
	_notice_left = duration


func prompt(at_x: float) -> String:
	if _notice_left > 0.0:
		return hint
	if at_x >= GAP_START - 480.0 and at_x <= GAP_END + 90.0:
		return "悬空墨桶 · 发光区按 K，空格飞到桶上，再按 J 弹到对岸。"
	if absf(at_x - FOLD_CENTRE) < 680.0 and not fold_targets.is_empty():
		return "散阵 · 靠近按 K 折纸聚敌，等它们靠拢后按 J 横斩。"
	if absf(at_x - boss_x) < 650.0:
		match boss_phase:
			BossPhase.ARMORED:
				return "墨梅 · J 打护甲（剩余 %d），留意脚下红色范围。" % boss_armor
			BossPhase.STAGGERED:
				return "墨梅失衡 · I 展开领域（%.1f 秒）" % boss_left
			BossPhase.SCROLL:
				return "白描里层 · J 连斩 %d / %d 笔（%.1f 秒）" % [boss_strokes, SCROLL_STROKES, boss_left]
			BossPhase.EXECUTE:
				return "墨梅跪地 · 近身按 F 落卷处决"
			BossPhase.FINISHING:
				return "墨梅 · 落卷"
	return ""


func _draw() -> void:
	if not active:
		return
	var bank := float(_floor_at.call(GAP_START))
	var lip := bank - 65.0
	draw_rect(Rect2(GAP_START, lip, GAP_END - GAP_START, 325.0), Color(0.06, 0.06, 0.09, 0.91))
	for edge in [GAP_START, GAP_END]:
		draw_line(Vector2(edge, lip), Vector2(edge, bank + 115.0), GOLD, 3.0, true)
	for start in [GAP_START - TAKEOFF_ZONE_WIDTH, GAP_END]:
		var mark := Vector2(start, float(_floor_at.call(start)) - 2.0)
		draw_line(mark, mark + Vector2(TAKEOFF_ZONE_WIDTH, 0.0), MINT, 5.0, true)
	var barrel_top := Vector2(BARREL_X, float(_floor_at.call(BARREL_X)) - BARREL_HEIGHT)
	var barrel_edge := Vector2(BARREL_CONTACT_HALF, 0.0)
	draw_rect(Rect2(barrel_top - barrel_edge, Vector2(BARREL_CONTACT_HALF * 2.0, 55.0)), INK)
	draw_line(barrel_top - barrel_edge, barrel_top + barrel_edge, MINT, 5.0, true)
	_tag("墨桶 · J 下劈反弹", barrel_top + Vector2(0.0, 80.0))
	if _barrel_flash > 0.0:
		var radius := 54.0 + 58.0 * (1.0 - _barrel_flash / 0.38)
		draw_arc(barrel_top, radius, PI, TAU, 36, Color(MINT, _barrel_flash / 0.38), 4.0, true)
	if fold_left > 0.0:
		var fold_foot := Vector2(fold_centre, float(_floor_at.call(fold_centre)) - 39.0)
		draw_arc(fold_foot, maxf(54.0, fold_left * 850.0), 0.0, TAU, 32, MINT, 3.0, true)
	if _mob_attack > 0.0:
		var floor_y := float(_floor_at.call(_mob_target_x))
		draw_line(Vector2(_mob_target_x - 96.0, floor_y), Vector2(_mob_target_x + 96.0, floor_y), RED, 8.0, true)
	_draw_boss()


func _draw_boss() -> void:
	if boss_phase == BossPhase.CLEARED:
		return
	var foot := Vector2(boss_x, float(_floor_at.call(boss_x)))
	if boss_counter > 0.0:
		draw_rect(Rect2(foot + Vector2(-95, -7), Vector2(190, 18)), RED)
	var crouch := boss_phase == BossPhase.EXECUTE or boss_phase == BossPhase.FINISHING
	var height := 146.0 if crouch else 222.0
	_tag("墨梅", foot - Vector2(0.0, height + 30.0))
	if boss_phase == BossPhase.SCROLL or boss_phase == BossPhase.EXECUTE:
		for index in range(SCROLL_STROKES):
			var mark := foot + Vector2(-68.0 + float(index) * 22.0, -height - 68.0)
			draw_line(mark, mark + Vector2(12.0, -9.0), MINT if index < boss_strokes else INK, 5.0, true)


func _sync_art(player_x: float) -> void:
	for index in range(fold_targets.size()):
		var target := fold_targets[index]
		var actor := _remaining_stele[index]
		actor.show()
		actor.position = Vector2(target, float(_floor_at.call(target)))
		actor.face(signf((fold_centre if fold_left > 0.0 else player_x) - target))
		if actor == _mob_attacker:
			actor.play_pose(&"stele_chop")
		else:
			var approaching := absf(player_x - target) > 85.0 and absf(player_x - target) < 260.0
			actor.play_pose(&"stele_walk" if fold_left > 0.0 or approaching else &"idle")

	_boss_visual.visible = boss_phase != BossPhase.CLEARED
	if boss_phase == BossPhase.CLEARED:
		return
	_boss_visual.position = Vector2(boss_x, float(_floor_at.call(boss_x)))
	_boss_visual.face(signf(player_x - boss_x))
	_boss_visual.modulate = Color(0.77, 1.0, 0.91) if boss_phase == BossPhase.STAGGERED else Color.WHITE
	if boss_phase == BossPhase.FINISHING:
		_boss_visual.modulate.a = boss_left / 0.32
	if boss_phase in [BossPhase.SCROLL, BossPhase.EXECUTE, BossPhase.FINISHING]:
		_boss_visual.play_pose(&"baimiao_stagger")
	elif boss_counter > 0.0:
		_boss_visual.play_pose(&"plum_lunge_phase_change")
	elif boss_moving:
		_boss_visual.play_pose(&"plum_glide")
	else:
		_boss_visual.play_pose(&"idle")


func _tag(label: String, centre: Vector2) -> void:
	var rect := Rect2(centre + Vector2(-93.0, -18.0), Vector2(186.0, 32.0))
	draw_rect(rect, INK)
	draw_string(ThemeDB.fallback_font, rect.position + Vector2(0.0, 22.0), label, HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, 20, PAPER)
