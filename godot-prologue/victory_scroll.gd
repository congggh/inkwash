extends Control

const INK := Color("#282420")
const PAPER := Color("#efe9da")
const RED := Color("#952e2d")
const GOLD := Color("#b29465")

var _score: Label
var _card: PanelContainer
var _seal: PanelContainer
var _actions: VBoxContainer
var _ranking_button: Button
var _tint: TextureRect
var _animation: Tween
var _total := 0
var _animating := true
var _stamp_played := false


func show_run(result: Dictionary, health: int) -> void:
	set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	mouse_filter = MOUSE_FILTER_STOP
	_total = result.score
	var font := SystemFont.new()
	font.font_names = PackedStringArray(["STKaiti", "KaiTi", "Kaiti SC", "Noto Serif CJK SC", "Microsoft YaHei"])
	theme = Theme.new()
	theme.default_font = font
	theme.default_font_size = 22
	theme.set_color("font_color", "Label", INK)

	var gradient := Gradient.new()
	gradient.offsets = PackedFloat32Array([0.0, 0.45, 1.0])
	gradient.colors = PackedColorArray([Color("#10100ecc"), Color("#10100e24"), Color("#10100e08")])
	var shade := GradientTexture2D.new()
	shade.gradient = gradient
	shade.fill_to = Vector2(1.0, 0.0)
	_tint = TextureRect.new()
	_tint.texture = shade
	_tint.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_tint.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	_tint.modulate.a = 0.0
	add_child(_tint)

	var place := CenterContainer.new()
	place.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	place.anchor_left = 0.02
	place.anchor_right = 0.44
	add_child(place)
	_card = PanelContainer.new()
	_card.custom_minimum_size.x = 438
	_card.add_theme_stylebox_override("panel", _box(PAPER, GOLD, 28, 23))
	_card.modulate.a = 0.0
	place.add_child(_card)
	var contents := VBoxContainer.new()
	contents.add_theme_constant_override("separation", 11)
	_card.add_child(contents)

	var heading := HBoxContainer.new()
	heading.add_theme_constant_override("separation", 19)
	contents.add_child(heading)
	_seal = PanelContainer.new()
	_seal.add_theme_stylebox_override("panel", _box(RED, Color("#c56a53"), 12, 5))
	var seal_text := _line("序章\n完", 36, PAPER)
	seal_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_seal.add_child(seal_text)
	_seal.modulate.a = 0.0
	heading.add_child(_seal)
	var identification := VBoxContainer.new()
	identification.size_flags_horizontal = SIZE_EXPAND_FILL
	identification.alignment = BoxContainer.ALIGNMENT_CENTER
	heading.add_child(identification)
	identification.add_child(_line("飞瀑收卷", 44))
	var name := _line(PlayerLedger.player_name(PlayerLedger.active_player), 21, RED)
	name.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	identification.add_child(name)
	contents.add_child(HSeparator.new())
	contents.add_child(_line("本局战绩", 19))
	_score = _line("0 分", 63, RED)
	contents.add_child(_score)
	contents.add_child(_line("用时  %s   ·   剩余生命  %d / 100" % [PlayerLedger.format_time(result.time), health], 20))
	if not result.saved:
		contents.add_child(_line("本局成绩保存失败", 18, RED))
	contents.add_child(HSeparator.new())

	_actions = VBoxContainer.new()
	_actions.add_theme_constant_override("separation", 8)
	_actions.modulate.a = 0.0
	contents.add_child(_actions)
	for index in 3:
		var captions := ["查看战绩榜", "重游序章", "返回题卷"]
		var button := Button.new()
		button.text = captions[index]
		button.custom_minimum_size.y = 43
		button.add_theme_stylebox_override("normal", _box(RED if index == 0 else PAPER, GOLD, 12, 4))
		button.add_theme_stylebox_override("hover", _box(Color("#6d3430"), GOLD, 12, 4))
		button.add_theme_stylebox_override("focus", _box(Color.TRANSPARENT, Color("#ca8548"), 12, 4))
		button.add_theme_color_override("font_color", PAPER if index == 0 else INK)
		button.add_theme_color_override("font_focus_color", PAPER if index == 0 else INK)
		button.pressed.connect(_leave.bind(index))
		_actions.add_child(button)
		if index == 0:
			_ranking_button = button
	# Keep the card at its final size while its controls are revealed.
	_actions.process_mode = Node.PROCESS_MODE_DISABLED
	for button: Button in _actions.get_children():
		button.disabled = true

	_animation = create_tween().set_ignore_time_scale(true)
	_animation.tween_property(_tint, "modulate:a", 1.0, 0.6)
	_animation.parallel().tween_property(_card, "modulate:a", 1.0, 0.5).set_delay(0.15)
	_animation.tween_callback(_drop_seal)
	_animation.tween_property(_seal, "scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_animation.tween_method(_count, 0, _total, 0.88).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_animation.tween_property(_actions, "modulate:a", 1.0, 0.24)
	_animation.tween_callback(_finish)


func _input(event: InputEvent) -> void:
	if _animating and (event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_cancel") or
			(event is InputEventMouseButton and event.pressed)):
		get_viewport().set_input_as_handled()
		_finish()


func _drop_seal() -> void:
	_seal.pivot_offset = _seal.size * 0.5
	_seal.scale = Vector2(1.62, 1.62)
	_seal.modulate.a = 1.0


func _count(amount: int) -> void:
	if not _stamp_played:
		ScoreAudio.cue(ScoreAudio.Cue.SEAL)
		_stamp_played = true
	_score.text = "%d 分" % amount


func _finish() -> void:
	if not _animating:
		return
	_animating = false
	_animation.kill()
	set_process_input(false)
	_tint.modulate.a = 1.0
	_card.modulate.a = 1.0
	_seal.modulate.a = 1.0
	_seal.scale = Vector2.ONE
	_count(_total)
	_actions.modulate.a = 1.0
	_actions.process_mode = Node.PROCESS_MODE_INHERIT
	for button: Button in _actions.get_children():
		button.disabled = false
	_ranking_button.grab_focus()


func _leave(index: int) -> void:
	PlayerLedger.open_results = index == 0
	get_tree().change_scene_to_file("res://levels.tscn" if index == 1 else PlayerLedger.TITLE)


func _line(text: String, font_size: int, color := INK) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	return label


func _box(color: Color, border: Color, x: int, y: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = border
	style.set_border_width_all(1)
	style.content_margin_left = x
	style.content_margin_right = x
	style.content_margin_top = y
	style.content_margin_bottom = y
	return style
