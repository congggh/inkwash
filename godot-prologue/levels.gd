extends Node2D

const RoadEncounters = preload("res://road_encounters.gd")
const InkHealth = preload("res://ink_health.gd")
const CombatFeedback = preload("res://combat_feedback.gd")
const RiftTrial = preload("res://rift_trial.gd")
const PrologueChallenges = preload("res://prologue_challenges.gd")
const ScrollReveal = preload("res://scroll_reveal.gd")
const VictoryScroll = preload("res://victory_scroll.gd")
const DefeatScroll = preload("res://defeat_scroll.gd")
enum AirMove { NONE, AIM, LAUNCH, POGO, BARREL }
const SLING_AIM_TIME := 0.20
const BARREL_AIM_TIME := 0.80
const SLING_TIME := 0.18
const SLING_SPEED := 2500.0
const POGO_SPEED := 1800.0
const LandscapeTile = preload("res://background/landscape_tile.gd")
const EXPLORE_CONTROLS := "A / D 移动    空格 跳跃    J 出刀    S + J 下劈    K 折纸 / 弹弓    I 领域    F 处决    R 重来"
const TRIAL_CONTROLS := "A / D 移动    空格 跳跃    J 三连斩    Shift 造缝    E 钻缝    F 弹反 / 处决    I 领域    R 重试"
const TRIAL_SLASHES: Array[StringName] = [&"slash_1", &"slash_2", &"slash_3"]
const TRIAL_SLASH_HIT_TIMES: Array[float] = [4.0 / 60.0, 3.0 / 60.0, 7.0 / 60.0]
const COMBO_BUFFER := 0.14
const TILE_WIDTH := 1914.0
const ART_HEIGHT := 822.0
const WALK_SPEED := 620.0
const PLAYBACK_SPEED := 780.0
const SPEED_CHANGE := 2800.0
const JUMP_SPEED := 690.0
const JUMP_ANIMATION_SPEED := 1.12
const GRAVITY := 2350.0
const EDGE_MARGIN := 80.0
const RAIN_BY_PANEL := [0.95, 0.75, 0.50, 0.15, 0.28, 0.58, 0.22, 0.34, 1.0, 0.79, 0.58, 0.0, 0.0]
const SUNLIGHT_X := Vector2(TILE_WIDTH + 1556.0, 2.0 * TILE_WIDTH + 1010.0)
const PLAYBACK_CUES := [
	{"position": 2.40, "action": &"jump"},
	{"position": 5.36, "action": &"jump"},
	{"position": 7.48, "action": &"jump"},
	{"position": 10.48, "action": &"attack"},
]

@export var auto_play := false

@onready var scenery: Node2D = %Scenery
@onready var camera: Camera2D = %Camera
@onready var player: Node2D = %Player
@onready var hero: Node2D = %MoHen
@onready var hero_sprite: AnimatedSprite2D = hero.get_node("Sprite")
@onready var scene_label: Label = %CurrentScene
@onready var transport: Button = %Transport
@onready var trial: RiftTrial = %RiftTrial
@onready var challenges: PrologueChallenges = %PrologueChallenges
@onready var trial_hint: Label = %TrialHint
@onready var controls: Label = %Controls
@onready var trial_visual: Node2D = %TrialVisual
@onready var trial_art: Node2D = %TrialVisual/MoHen
@onready var trial_anim: AnimationPlayer = %TrialVisual/MoHen/AnimationPlayer

var segments: Array
var visible_tiles: Dictionary[int, LandscapeTile] = {}
var sunlight := Vector2.ZERO
var storm_age := -1.0
var storm_triggered := false
var gravel_age := Vector2(-1.0, -1.0)
var gravel_triggered := [false, false]
var inner_track := false
var player_x := 0.0
var horizontal_speed := 0.0
var jump_height := 0.0
var jump_speed := 0.0
var jump_requested := false
var course_end := 0.0
var playback_paused := false
var intro_remaining := 0.0
var cue_index := 0
var trial_attack_index := -1
var trial_attack_time := 0.0
var trial_hit_pending := false
var trial_combo_pending := false
var air_move := AirMove.NONE
var air_timer := 0.0
var sling_velocity := Vector2.ZERO
var sling_spent := false
var guided_sling := false
var barrel_exit_direction := 1.0
var barrel_bounce_buffered := false
var barrel_crossing := false
var special_left := 0.0
var heavy_hit_left := 0.0
var boss_override := false
var combat_fx: CombatFeedback
var road: RoadEncounters
var ink_health: InkHealth
var domain_hint_left := 0.0
var run_started_at := 0
var run_finished := false
var intro_opening := false
var boss_music := false
var _entrance: Tween
var _defeat_layer: CanvasLayer


func _ready() -> void:
	var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://levels.json"))
	segments = data["segments"]
	course_end = segments.size() * TILE_WIDTH - EDGE_MARGIN
	transport.visible = auto_play
	transport.pressed.connect(_toggle_playback)
	controls.visible = not auto_play
	if not auto_play:
		combat_fx = CombatFeedback.new()
		combat_fx.z_index = 3
		add_child(combat_fx)
		trial.enemy_windup.connect(_on_enemy_windup)
		trial.player_hurt.connect(_on_player_hurt)
		trial.enemy_hurt.connect(_on_enemy_hurt)
		challenges.enemy_windup.connect(_on_enemy_windup)
		challenges.enemy_hurt.connect(_on_enemy_hurt)
		trial.open(_floor_at(RiftTrial.START_X))
		trial.parried.connect(_on_parried)
		challenges.setup(_floor_at)
		road = RoadEncounters.new()
		road.z_index = 1
		add_child(road)
		road.setup(_floor_at)
		road.enemy_windup.connect(_on_enemy_windup)
		road.enemy_hurt.connect(_on_enemy_hurt)
		road.player_hit.connect(_take_damage)
		ink_health = InkHealth.new()
		ink_health.position = Vector2(30.0, 28.0)
		ink_health.mouse_filter = Control.MOUSE_FILTER_IGNORE
		$HUD.add_child(ink_health)
		challenges.boss_track_requested.connect(_on_boss_track)
		challenges.player_hit.connect(_on_boss_hit)
		hero.hide()
		trial_visual.show()
		trial_hint.show()
	get_viewport().size_changed.connect(_fit_camera)
	_fit_camera()
	_restart()
	if not auto_play and not PlayerLedger.active_player.is_empty():
		intro_opening = true
		$HUD.hide()
		var scroll := ScrollReveal.new()
		_cinematic_layer().add_child(scroll)
		scroll.opened.connect(_begin_ranked_play)
		scroll.reveal("墨痕登场", "序章  ·  断云台")
		trial_visual.position.x = -94.0
		trial_anim.play(&"run")
		_entrance = create_tween().set_ignore_time_scale(true)
		_entrance.tween_property(trial_visual, "position:x", 0.0, 0.52).set_delay(0.62).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)


func _begin_ranked_play() -> void:
	_entrance.kill()
	trial_visual.position.x = 0.0
	trial_anim.play(&"idle")
	intro_opening = false
	run_started_at = Time.get_ticks_msec()
	$HUD.show()


func _cinematic_layer() -> CanvasLayer:
	var layer := CanvasLayer.new()
	layer.layer = 110
	add_child(layer)
	return layer


func _process(delta: float) -> void:
	if combat_fx == null:
		return
	domain_hint_left = maxf(0.0, domain_hint_left - delta)
	ink_health.update_health(trial.health, RiftTrial.MAX_HEALTH, delta)
	if _defeat_layer:
		return
	var strength := combat_fx.shake
	camera.offset = Vector2(sin(Time.get_ticks_msec() * 0.13), cos(Time.get_ticks_msec() * 0.17)) * strength
	trial_visual.modulate = Color(1.0, 0.38, 0.33) if combat_fx.hurt > 0.0 and int(combat_fx.hurt * 30.0) % 2 == 0 else Color.WHITE
	for tile in visible_tiles.values():
		tile.update_ink(combat_fx.origin, combat_fx.radius, combat_fx.stains)


func _physics_process(delta: float) -> void:
	if intro_opening or run_finished or playback_paused:
		return
	if trial.active and trial.health <= 0:
		_show_defeat()
		return
	var course_active := trial.active and trial.cleared
	var direction := _get_direction(delta)
	var frozen := trial.parry_freeze_left > 0.0
	var boss_finishing := course_active and challenges.boss_phase == PrologueChallenges.BossPhase.FINISHING
	if jump_requested and _at_ground() and not trial.is_rushing() and not frozen and not boss_finishing:
		if not course_active or not challenges.is_over_gap(player_x):
			jump_speed = JUMP_SPEED
	jump_requested = false

	if course_active and (air_move == AirMove.AIM or air_move == AirMove.LAUNCH):
		_advance_slingshot(delta)
	elif not frozen and not boss_finishing and air_move != AirMove.BARREL:
		var previous := Vector2(player_x, jump_height)
		_advance_walking(delta, direction, course_active)
		if trial.active:
			var before := player_x
			player_x = trial.advance(delta, player_x, jump_height != 0.0 or jump_speed != 0.0)
			if not is_equal_approx(player_x, before):
				hero_sprite.scale.x = signf(player_x - before)
		_advance_vertical(delta, previous, course_active)
	elif frozen:
		trial.advance(delta, player_x, false)
		if trial.parry_freeze_left <= 0.0:
			trial_anim.play(&"parry_peel")

	if course_active:
		challenges.advance(delta * (0.20 if air_move == AirMove.AIM else 1.0),
			player_x, jump_height, air_move == AirMove.LAUNCH)
		_update_music()
		road.advance(delta, player_x, jump_height, air_move == AirMove.LAUNCH)
		_tick_special(delta)
	elif not frozen:
		special_left = maxf(0.0, special_left - delta)

	if trial.active and trial.health <= 0:
		_update_world()
		_show_defeat()
		return

	hero.position.y = -jump_height
	if trial.active:
		trial_visual.position.y = -jump_height
		var facing := hero_sprite.scale.x
		trial_art.transform = Transform2D(Vector2(facing, 0), Vector2.DOWN, Vector2.ZERO)
		if not frozen and not boss_finishing:
			_update_trial_attack(delta)
	_update_animation()
	_update_sunlight(delta)
	_update_storm(delta)
	_update_foreground_gravel(delta)
	_update_world()
	if auto_play and player_x >= course_end:
		transport.text = "重播"
	elif course_active and challenges.boss_phase == PrologueChallenges.BossPhase.CLEARED and player_x >= course_end and jump_height == 0.0:
		_finish_ranked_run()


func _finish_ranked_run() -> void:
	if run_finished or PlayerLedger.active_player.is_empty():
		return
	run_finished = true
	PlayerLedger.complete_prologue(Time.get_ticks_msec() - run_started_at, trial.health)
	$HUD.hide()
	trial_anim.play(&"brake")
	ScoreAudio.music(ScoreAudio.Track.VICTORY)
	var victory := VictoryScroll.new()
	_cinematic_layer().add_child(victory)
	victory.show_run(PlayerLedger.last_run, trial.health)


func _show_defeat() -> void:
	run_finished = true
	horizontal_speed = 0.0
	camera.offset = Vector2.ZERO
	trial_anim.pause()
	trial_visual.modulate = Color("#9f8d81")
	$HUD/Margins.hide()
	ScoreAudio.music(ScoreAudio.Track.DEFEAT)
	_defeat_layer = _cinematic_layer()
	var defeat := DefeatScroll.new()
	_defeat_layer.add_child(defeat)
	defeat.retry_requested.connect(_restart)
	defeat.title_requested.connect(func() -> void:
		get_tree().change_scene_to_file(PlayerLedger.TITLE)
	)


func _update_music() -> void:
	var distance := absf(player_x - PrologueChallenges.BOSS_X)
	var playing_boss := challenges.boss_phase != PrologueChallenges.BossPhase.CLEARED and distance < (1130.0 if boss_music else 690.0)
	if boss_music != playing_boss:
		boss_music = playing_boss
		ScoreAudio.music(ScoreAudio.Track.BOSS if boss_music else ScoreAudio.Track.ROAD)


func _advance_walking(delta: float, direction: float, course_active: bool) -> void:
	if trial.active and trial.is_rushing():
		return
	if barrel_crossing:
		var landing_x := PrologueChallenges.GAP_END + 65.0 if barrel_exit_direction > 0.0 else PrologueChallenges.GAP_START - 65.0
		player_x = move_toward(player_x, landing_x, WALK_SPEED * 1.45 * delta)
		hero_sprite.scale.x = barrel_exit_direction
		return
	var speed := PLAYBACK_SPEED if auto_play else WALK_SPEED
	var right_edge := course_end
	if course_active:
		right_edge = road.right_limit(challenges.right_limit(course_end))
	elif trial.active:
		right_edge = RiftTrial.END_X
	var locked := _is_striking() or (course_active and air_move == AirMove.POGO)
	var target_speed := 0.0 if locked else direction * speed
	horizontal_speed = move_toward(horizontal_speed, target_speed, SPEED_CHANGE * delta)
	var goal := clampf(player_x + horizontal_speed * delta, EDGE_MARGIN, right_edge)
	player_x = road.resolve_motion(player_x, goal, jump_height) if course_active else goal
	if not is_equal_approx(player_x, goal):
		horizontal_speed = 0.0
	if player_x == EDGE_MARGIN or player_x == right_edge:
		horizontal_speed = 0.0
	if direction != 0.0 and not locked:
		hero_sprite.scale.x = signf(direction)


func _ground_height() -> float:
	return road.ground_height(player_x) if road != null and trial.cleared else 0.0


func _at_ground() -> bool:
	return is_equal_approx(jump_height, _ground_height()) and jump_speed == 0.0


func _advance_vertical(delta: float, previous: Vector2, course_active: bool) -> void:
	var in_gap := course_active and challenges.is_over_gap(player_x)
	var floor_height := _ground_height()
	if jump_speed != 0.0 or jump_height != 0.0 or in_gap:
		jump_speed -= GRAVITY * delta
		jump_height += jump_speed * delta
		if air_move == AirMove.POGO and challenges.pogo_contact(previous, Vector2(player_x, jump_height)):
			jump_height = PrologueChallenges.BARREL_HEIGHT
			jump_speed = POGO_SPEED
			barrel_crossing = true
			sling_spent = false
			air_move = AirMove.NONE
		elif course_active and air_move == AirMove.NONE and challenges.barrel_below(previous, Vector2(player_x, jump_height)):
			_perch_on_barrel()
		elif not in_gap and previous.y >= floor_height and jump_height <= floor_height:
			jump_height = floor_height
			barrel_crossing = false
			jump_speed = 0.0
			sling_spent = false
			air_move = AirMove.NONE
		if jump_height < -260.0 and course_active:
			player_x = challenges.on_fall()
			barrel_crossing = false
			barrel_bounce_buffered = false
			horizontal_speed = 0.0
			jump_height = 0.0
			jump_speed = 0.0
			sling_spent = false
			air_move = AirMove.NONE
			special_left = 0.0


func _advance_slingshot(delta: float) -> void:
	var step := minf(delta, air_timer)
	air_timer = maxf(0.0, air_timer - delta)
	if air_move == AirMove.AIM:
		if air_timer == 0.0:
			_release_slingshot()
		return
	var edge := road.right_limit(challenges.right_limit(course_end))
	var goal := clampf(player_x + sling_velocity.x * step, EDGE_MARGIN, edge)
	player_x = road.resolve_motion(player_x, goal, jump_height)
	jump_height -= sling_velocity.y * step
	if not challenges.is_over_gap(player_x) and jump_height <= 0.0:
		air_move = AirMove.NONE
		jump_height = 0.0
		jump_speed = 0.0
		sling_spent = false
	elif air_timer == 0.0:
		if guided_sling:
			_perch_on_barrel()
		else:
			air_move = AirMove.NONE
			jump_speed = 0.0


func _perch_on_barrel() -> void:
	if not guided_sling:
		barrel_exit_direction = -1.0 if challenges.gap_crossed else 1.0
	player_x = PrologueChallenges.BARREL_X
	jump_height = PrologueChallenges.BARREL_HEIGHT + 10.0
	jump_speed = 0.0
	horizontal_speed = 0.0
	air_move = AirMove.BARREL
	if barrel_bounce_buffered:
		_start_pogo()
	else:
		trial_anim.play(&"idle")


func _start_pogo() -> void:
	barrel_bounce_buffered = false
	air_move = AirMove.POGO
	jump_speed = -POGO_SPEED
	special_left = 0.20
	trial_anim.play(&"pogo")


func _release_slingshot() -> void:
	var aim := Vector2(Input.get_axis("walk_left", "walk_right"), Input.get_axis("aim_up", "aim_down"))
	var toward_barrel := signf(PrologueChallenges.BARREL_X - player_x)
	var near_barrel_route := challenges.near_takeoff(player_x)
	if near_barrel_route:
		aim = Vector2(toward_barrel, 0.0)
	elif aim.is_zero_approx():
		aim.x = hero_sprite.scale.x
	if not is_zero_approx(aim.x):
		hero_sprite.scale.x = signf(aim.x)
	guided_sling = near_barrel_route and is_zero_approx(aim.y) and signf(aim.x) == toward_barrel
	if guided_sling:
		barrel_exit_direction = toward_barrel
		jump_height = maxf(jump_height, PrologueChallenges.BARREL_HEIGHT + 55.0)
		sling_velocity = Vector2((PrologueChallenges.BARREL_X - player_x) / SLING_TIME, 0.0)
	else:
		sling_velocity = aim.normalized() * SLING_SPEED
	air_move = AirMove.LAUNCH
	air_timer = SLING_TIME
	sling_spent = true
	trial_anim.stop()
	trial_anim.play(&"rift_slingshot")


func _tick_special(delta: float) -> void:
	special_left = maxf(0.0, special_left - delta)
	if heavy_hit_left <= 0.0:
		return
	heavy_hit_left = maxf(0.0, heavy_hit_left - delta)
	if heavy_hit_left == 0.0 and challenges.open_scroll(player_x, hero_sprite.scale.x, combat_fx.domain_left):
		special_left = 0.15
		trial_anim.play(&"scroll_flip")


func _on_parried() -> void:
	ScoreAudio.cue(ScoreAudio.Cue.PARRY)
	trial_attack_index = -1
	horizontal_speed = 0.0
	special_left = 0.24
	trial_anim.play(&"parry_peel")
	trial_anim.advance(0.0)
	trial_anim.pause()


func _on_enemy_windup() -> void:
	combat_fx.cue(&"swing", 2.0)


func _on_enemy_hurt(at_x: float, facing: float, charge: int) -> void:
	combat_fx.land_hit(at_x, _floor_at(at_x), facing, charge)


func _on_player_hurt(source_x: float) -> void:
	combat_fx.receive_hit()
	trial_attack_index = -1
	heavy_hit_left = 0.0
	special_left = 0.20
	horizontal_speed = signf(player_x - source_x) * 480.0
	trial_anim.stop()
	trial_anim.play(&"idle")


func _on_boss_hit(source_x: float) -> void:
	_take_damage(source_x, 20 if absf(source_x - challenges.boss_x) < 1.0 else 12)


func _take_damage(source_x: float, amount: int) -> void:
	if combat_fx.hurt > 0.0:
		return
	trial.health = maxi(0, trial.health - amount)
	_on_player_hurt(source_x)


func _on_boss_track(use_inner: bool) -> void:
	boss_override = use_inner


func _activate_domain() -> void:
	if trial.health <= 0 or air_move != AirMove.NONE or trial.is_rushing() or boss_override:
		return
	var opening_boss := trial.cleared and challenges.boss_phase == PrologueChallenges.BossPhase.STAGGERED 		and absf(challenges.boss_x - player_x) <= 170.0
	if not combat_fx.expand(Vector2(player_x, _floor_at(player_x) - jump_height - 55.0)):
		domain_hint_left = 1.6
		return
	domain_hint_left = 0.0
	if opening_boss:
		hero_sprite.scale.x = signf(challenges.boss_x - player_x)
		trial_attack_index = -1
		heavy_hit_left = 0.12
		special_left = 0.36
		horizontal_speed = 0.0
		trial_anim.play(&"heavy_starter")


func _get_direction(delta: float) -> float:
	if not auto_play:
		return Input.get_axis("walk_left", "walk_right")
	if intro_remaining > 0.0:
		intro_remaining -= delta
		return 0.0
	if player_x >= course_end:
		return 0.0
	if cue_index < PLAYBACK_CUES.size():
		var cue: Dictionary = PLAYBACK_CUES[cue_index]
		if player_x >= float(cue["position"]) * TILE_WIDTH:
			cue_index += 1
			if cue["action"] == &"jump":
				jump_requested = true
			else:
				_strike()
	return 1.0


func _is_striking() -> bool:
	if trial.active:
		return special_left > 0.0 or trial.parry_freeze_left > 0.0 or trial_attack_index >= 0 or (trial_anim.current_animation == &"paper_rip" and trial_anim.is_playing())
	return hero_sprite.animation == &"attack" and hero_sprite.is_playing()


func _strike() -> void:
	if not _at_ground() or jump_requested:
		return
	if trial.active:
		if trial_attack_index >= 0:
			var clip := trial_anim.get_animation(TRIAL_SLASHES[trial_attack_index])
			var remaining := clip.length - trial_attack_time
			if trial_attack_index < TRIAL_SLASHES.size() - 1 and remaining <= COMBO_BUFFER:
				trial_combo_pending = true
		elif not _is_striking():
			_start_trial_attack(0)
	elif not _is_striking():
		horizontal_speed = 0.0
		hero_sprite.play(&"attack")


func _start_trial_attack(index: int) -> void:
	trial_attack_index = index
	trial_attack_time = 0.0
	trial_hit_pending = true
	trial_combo_pending = false
	horizontal_speed = 0.0
	trial_anim.play(TRIAL_SLASHES[index])


func _update_trial_attack(delta: float) -> void:
	if trial_attack_index < 0:
		return
	trial_attack_time += delta
	if trial_hit_pending and trial_attack_time >= TRIAL_SLASH_HIT_TIMES[trial_attack_index]:
		trial_hit_pending = false
		if not trial.cleared:
			if trial_attack_index == 2:
				trial.cut_rift(player_x, hero_sprite.scale.x)
			trial.attack(player_x, hero_sprite.scale.x)
		else:
			if road.slash(player_x, hero_sprite.scale.x):
				combat_fx.cue(&"strike", 6.0)
			else:
				challenges.slash(player_x, hero_sprite.scale.x)
	var clip := trial_anim.get_animation(TRIAL_SLASHES[trial_attack_index])
	if trial_attack_time < clip.length:
		return
	if trial_combo_pending and trial.health > 0:
		_start_trial_attack(trial_attack_index + 1)
	else:
		trial_attack_index = -1


func _update_animation() -> void:
	if trial.active:
		if trial.is_rushing() or _is_striking() or air_move != AirMove.NONE:
			return
		var clip := &"jump" if not _at_ground() else (&"run" if absf(horizontal_speed) > 25.0 else &"idle")
		if trial_anim.assigned_animation != clip:
			trial_anim.play(clip, -1.0, 0.4 if clip == &"jump" else 1.0)
		return
	if _is_striking():
		return
	if jump_height > 0.0:
		if hero_sprite.animation != &"jump":
			hero_sprite.play(&"jump", JUMP_ANIMATION_SPEED)
		return
	var ground_animation := &"run" if absf(horizontal_speed) > 25.0 else &"idle"
	if hero_sprite.animation != ground_animation or not hero_sprite.is_playing() or not is_equal_approx(hero_sprite.get_playing_speed(), 1.0):
		hero_sprite.play(ground_animation)


func _unhandled_key_input(event: InputEvent) -> void:
	if intro_opening or run_finished or not event.is_pressed() or event.is_echo():
		return
	if trial.active and (event.physical_keycode == KEY_I or event.keycode == KEY_I):
		_activate_domain()
		get_viewport().set_input_as_handled()
		return
	if trial.active and ((trial.cleared and _handle_course_key(event)) or _handle_trial_key(event)):
		get_viewport().set_input_as_handled()
		return
	if event.is_action("jump"):
		if auto_play:
			_toggle_playback()
		elif not _is_striking():
			jump_requested = true
	elif event.is_action("strike") and not auto_play and not (trial.active and (trial.is_rushing() or trial.health <= 0)):
		_strike()
	elif event.is_action("switch_track") and not boss_override:
		_set_track(not inner_track)
	elif event.is_action("restart_level"):
		_restart()
	elif event.is_action("ui_cancel"):
		if auto_play or PlayerLedger.active_player.is_empty():
			_open_gallery()
		else:
			get_tree().change_scene_to_file(PlayerLedger.TITLE)
	else:
		return
	get_viewport().set_input_as_handled()


func _handle_course_key(event: InputEventKey) -> bool:
	var key := event.physical_keycode if event.physical_keycode != KEY_NONE else event.keycode
	if trial.health <= 0 or challenges.boss_phase == PrologueChallenges.BossPhase.FINISHING:
		return key in [KEY_K, KEY_I, KEY_F, KEY_J, KEY_SPACE]
	if key == KEY_SPACE and air_move == AirMove.AIM:
		_release_slingshot()
		return true
	if key == KEY_K:
		var near_bank := challenges.near_takeoff(player_x)
		var can_hop := near_bank and jump_height >= -55.0 and not _is_striking()
		if (jump_height > _ground_height() or can_hop) and air_move == AirMove.NONE and not sling_spent:
			if can_hop:
				jump_height = PrologueChallenges.BARREL_HEIGHT + 55.0
				jump_speed = 0.0
			air_move = AirMove.AIM
			air_timer = BARREL_AIM_TIME if near_bank else SLING_AIM_TIME
			horizontal_speed = 0.0
			trial_anim.play(&"rift_slingshot")
		elif _at_ground() and air_move == AirMove.NONE and not _is_striking() and challenges.fold(player_x, hero_sprite.scale.x):
			special_left = 0.24
			horizontal_speed = 0.0
			trial_anim.play(&"spatial_fold")
		return true
	if key == KEY_J and air_move == AirMove.LAUNCH and guided_sling:
		barrel_bounce_buffered = true
		return true
	if key == KEY_J and jump_height > _ground_height() and (air_move == AirMove.BARREL or Input.is_action_pressed("aim_down")):
		if air_move == AirMove.NONE or air_move == AirMove.BARREL:
			_start_pogo()
		return true
	if key == KEY_J and challenges.boss_phase == PrologueChallenges.BossPhase.SCROLL:
		if challenges.scroll_slash(player_x):
			trial_anim.stop()
			trial_anim.play(TRIAL_SLASHES[(challenges.boss_strokes - 1) % TRIAL_SLASHES.size()])
			special_left = 0.12
		return true
	if key == KEY_F and jump_height == 0.0 and challenges.finish_boss(player_x):
		trial_attack_index = -1
		special_left = 0.32
		horizontal_speed = 0.0
		trial_anim.play(&"scroll_finish")
		return true
	return false


func _handle_trial_key(event: InputEventKey) -> bool:
	var key := event.physical_keycode if event.physical_keycode != KEY_NONE else event.keycode
	if key != KEY_SHIFT and key != KEY_E and key != KEY_F:
		return false
	if trial.is_over() or jump_height > 0.0 or jump_requested or trial.parry_freeze_left > 0.0:
		return true
	match key:
		KEY_SHIFT:
			if trial.dash(player_x, hero_sprite.scale.x):
				horizontal_speed = 0.0
				trial_attack_index = -1
				trial_anim.play(&"dash")
		KEY_E:
			if trial.grind(player_x):
				horizontal_speed = 0.0
				trial_attack_index = -1
				trial_anim.play(&"rift_grind")
		KEY_F:
			if trial.try_parry(player_x):
				_update_world()
				return true
			var finishes := trial.rift_finishes
			var facing := 1.0 if player_x <= trial.enemy_x else -1.0
			player_x = trial.finish(player_x)
			if trial.rift_finishes > finishes:
				horizontal_speed = 0.0
				trial_attack_index = -1
				hero_sprite.scale.x = facing
				trial_art.transform = Transform2D(Vector2(facing, 0), Vector2.DOWN, Vector2.ZERO)
				trial_anim.play(&"paper_rip")
	_update_world()
	return true


func _restart() -> void:
	if _defeat_layer:
		_defeat_layer.hide()
		_defeat_layer.queue_free()
		_defeat_layer = null
		$HUD/Margins.show()
	boss_music = false
	ScoreAudio.music(ScoreAudio.Track.ROAD)
	run_started_at = Time.get_ticks_msec()
	run_finished = false
	if trial.active:
		combat_fx.reset()
		domain_hint_left = 0.0
		_on_boss_track(false)
		trial.reset()
		challenges.reset()
		road.reset()
	air_move = AirMove.NONE
	air_timer = 0.0
	sling_spent = false
	guided_sling = false
	barrel_crossing = false
	barrel_bounce_buffered = false
	special_left = 0.0
	heavy_hit_left = 0.0
	trial_attack_index = -1
	trial_visual.position.y = 0.0
	trial_art.transform = Transform2D.IDENTITY
	trial_anim.stop()
	if trial.active:
		trial_anim.play(&"idle")
	player_x = RiftTrial.START_X
	sunlight = Vector2.ZERO
	storm_age = -1.0
	storm_triggered = false
	gravel_age = Vector2(-1.0, -1.0)
	gravel_triggered.fill(false)
	horizontal_speed = 0.0
	jump_height = 0.0
	jump_speed = 0.0
	jump_requested = false
	playback_paused = false
	intro_remaining = 0.65 if auto_play else 0.0
	cue_index = 0
	transport.text = "暂停"
	hero.position.y = 0.0
	hero_sprite.scale.x = 1.0
	hero_sprite.stop()
	hero_sprite.play(&"idle")
	_update_world()


func _toggle_playback() -> void:
	if player_x >= course_end:
		_restart()
		return
	playback_paused = not playback_paused
	transport.text = "继续" if playback_paused else "暂停"
	if playback_paused:
		hero_sprite.pause()
	else:
		var speed := JUMP_ANIMATION_SPEED if hero_sprite.animation == &"jump" else 1.0
		hero_sprite.play(hero_sprite.animation, speed)


func _fit_camera() -> void:
	camera.zoom = Vector2.ONE * get_viewport_rect().size.y / ART_HEIGHT
	if not segments.is_empty():
		_update_world()


func _floor_at(x: float) -> float:
	var segment_position := x / TILE_WIDTH
	var index := clampi(floori(segment_position), 0, segments.size() - 1)
	var floor_y := float(segments[index]["floor"])
	var progress := segment_position - index
	# Ease between the painted walking heights near each join.
	if progress < 0.25 and index > 0:
		var left := float(segments[index - 1]["floor"])
		return lerpf((left + floor_y) * 0.5, floor_y, smoothstep(0.0, 0.25, progress))
	if progress > 0.75 and index + 1 < segments.size():
		var right := float(segments[index + 1]["floor"])
		return lerpf(floor_y, (floor_y + right) * 0.5, smoothstep(0.75, 1.0, progress))
	return floor_y


func _update_world() -> void:
	player.position = Vector2(player_x, _floor_at(player_x))
	var half_width := get_viewport_rect().size.x / camera.zoom.x * 0.5
	var half_art := segments.size() * TILE_WIDTH * 0.5
	camera.position.x = clampf(player_x, minf(half_width, half_art),
		maxf(half_art, 2.0 * half_art - half_width))
	var start_x := camera.position.x - half_width
	var end_x := camera.position.x + half_width
	_sync_tiles(start_x, end_x)
	var foreground_motion := clampf(horizontal_speed / 620.0, -1.0, 1.0)
	for tile in visible_tiles.values():
		tile.update_view(camera.position.x, sunlight, player_x, storm_age, foreground_motion, gravel_age)

	var index := clampi(floori(player_x / TILE_WIDTH), 0, segments.size() - 1)
	if trial.active and not trial.cleared:
		scene_label.text = trial.status_text()
	else:
		scene_label.text = segments[index]["title"]
		if player_x >= course_end:
			scene_label.text = "序章播放完毕" if auto_play else "长卷终点 · 已走完序章"

	if trial.active:
		scene_label.text += "    能量 %d/100" % combat_fx.energy
		if combat_fx.domain_left > 0.0:
			scene_label.text += " · 领域 %.1f 秒" % combat_fx.domain_left
		elif combat_fx.radius > 0.0:
			scene_label.text += " · 领域收回中"
		elif combat_fx.energy >= CombatFeedback.DOMAIN_COST:
			scene_label.text += " · I 展开领域"
		var stage_hint := trial.hint if not trial.cleared or index == 0 else challenges.prompt(player_x)
		if combat_fx.hurt > 0.0:
			stage_hint = "受击 · 生命 %d/%d" % [trial.health, RiftTrial.MAX_HEALTH]
		elif domain_hint_left > 0.0:
			stage_hint = "领域需要 60 点能量。命中、弹反和处决可以积累。"
		elif air_move == AirMove.AIM:
			stage_hint = "按空格弹向墨桶。" if challenges.near_takeoff(player_x) else "W / A / S / D 选方向，按空格弹射。"
		elif air_move == AirMove.BARREL:
			stage_hint = "已站上墨桶。按 J 下劈反弹，就会飞向对岸。"
		elif challenges.is_over_gap(player_x) and jump_height > PrologueChallenges.BARREL_HEIGHT and absf(player_x - PrologueChallenges.BARREL_X) <= 80.0:
			stage_hint = "已到墨桶上方。按住 S，再按 J 下劈反弹。"
		trial_hint.visible = not stage_hint.is_empty()
		trial_hint.text = stage_hint
		controls.text = EXPLORE_CONTROLS if trial.cleared else TRIAL_CONTROLS


func _sync_tiles(start_x: float, end_x: float) -> void:
	var first := maxi(0, floori(start_x / TILE_WIDTH) - 1)
	var last := mini(segments.size() - 1, floori(end_x / TILE_WIDTH) + 1)
	for index in visible_tiles.keys():
		if index < first or index > last:
			visible_tiles[index].free()
			visible_tiles.erase(index)
	for index in range(first, last + 1):
		if not visible_tiles.has(index):
			visible_tiles[index] = _make_tile(index)


func _make_tile(index: int) -> LandscapeTile:
	var tile := LandscapeTile.new()
	tile.position.x = TILE_WIDTH * index
	scenery.add_child(tile)
	tile.setup(index, float(segments[index]["floor"]) - 43.0, segments[index]["tile"] == "07")
	_apply_landscape_track(index, tile)
	return tile


func _texture_for(index: int) -> Texture2D:
	if index < 0 or index >= segments.size():
		return null
	var track := "inner" if inner_track else "surface"
	return load("res://art/levels/%s_%s.jpg" % [track, segments[index]["tile"]]) as Texture2D


func _apply_landscape_track(index: int, tile: LandscapeTile) -> void:
	var following := _texture_for(index + 1)
	if not inner_track and index + 1 < segments.size() and segments[index + 1]["tile"] == "07":
		# Only the left edge of the following panel is sampled across this join.
		following = LandscapeTile.StelePlate
	tile.set_track(_texture_for(index), _texture_for(index - 1), following, inner_track)
	tile.effect.set_shader_parameter(&"white_art", load("res://art/levels/inner_%s.jpg" % segments[index]["tile"]))


func _update_sunlight(delta: float) -> void:
	var ravine := 1.0 - smoothstep(155.0, 500.0, absf(player_x - SUNLIGHT_X.x))
	var gate := 1.0 - smoothstep(155.0, 500.0, absf(player_x - SUNLIGHT_X.y))
	sunlight.x = move_toward(sunlight.x, ravine, delta * (0.69 if ravine > sunlight.x else 0.48))
	sunlight.y = move_toward(sunlight.y, gate, delta * (0.69 if gate > sunlight.y else 0.48))


func _update_storm(delta: float) -> void:
	var local_x := player_x - 8.0 * TILE_WIDTH
	if storm_age >= 0.0:
		storm_age += delta
		if storm_age > 0.68:
			storm_age = -1.0
	if local_x < 450.0 or local_x > 1340.0:
		storm_triggered = false
	if not inner_track and not storm_triggered and local_x >= 625.0 and local_x <= 1150.0:
		storm_triggered = true
		storm_age = 0.0


func _update_foreground_gravel(delta: float) -> void:
	var local_x := player_x - 5.0 * TILE_WIDTH
	var ledges := Vector2(310.0, 1675.0)
	for side in range(2):
		if gravel_age[side] >= 0.0:
			gravel_age[side] += delta
			if gravel_age[side] > 1.1:
				gravel_age[side] = -1.0
		var distance := absf(local_x - ledges[side])
		if distance > 250.0:
			gravel_triggered[side] = false
		elif distance < 165.0 and absf(horizontal_speed) > 75.0 and not inner_track and not gravel_triggered[side]:
			gravel_triggered[side] = true
			gravel_age[side] = 0.0


func rain_strength_at(x: float) -> float:
	var panel_pos := clampf(x / TILE_WIDTH, 0.0, float(segments.size()) - 0.001)
	var left := clampi(floori(panel_pos - 0.5), 0, RAIN_BY_PANEL.size() - 2)
	var weight := smoothstep(-0.21, 0.21, panel_pos - float(left + 1))
	return lerpf(RAIN_BY_PANEL[left], RAIN_BY_PANEL[left + 1], weight)


func _set_track(use_inner: bool) -> void:
	if inner_track == use_inner:
		return
	inner_track = use_inner
	$FarRain.visible = not inner_track
	$NearRain.visible = not inner_track
	for index in visible_tiles:
		_apply_landscape_track(index, visible_tiles[index])


func _open_gallery() -> void:
	get_tree().change_scene_to_file("res://preview.tscn")
