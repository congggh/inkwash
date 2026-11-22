extends Control

signal opened

const PAPER := Color("#d8c8a8")
const DARK := Color("#2d2420")
const GOLD := Color("#aa8960")

var _spread := 0.0
var _tween: Tween
var _grain := PackedVector2Array()
var _caption := ""
var _subtitle := ""
var _font := SystemFont.new()


func _ready() -> void:
	set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	mouse_filter = MOUSE_FILTER_STOP
	_font.font_names = PackedStringArray(["STKaiti", "KaiTi", "Kaiti SC", "Noto Serif CJK SC", "Microsoft YaHei"])
	var random := RandomNumberGenerator.new()
	random.seed = 4321
	for index in 285:
		_grain.append(Vector2(random.randf(), random.randf()))


func reveal(caption := "", subtitle := "") -> void:
	_caption = caption
	_subtitle = subtitle
	ScoreAudio.cue(ScoreAudio.Cue.UNROLL)
	_tween = create_tween().set_ignore_time_scale(true)
	if not caption.is_empty():
		_tween.tween_interval(0.36)
	_tween.tween_method(_set_spread, 0.0, 1.0, 0.85).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN_OUT)
	_tween.tween_callback(_finish)


func _input(event: InputEvent) -> void:
	var skip := event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_cancel")
	if skip or (event is InputEventMouseButton and event.pressed):
		get_viewport().set_input_as_handled()
		_finish()


func _finish() -> void:
	if _tween:
		_tween.kill()
	set_process_input(false)
	hide()
	opened.emit()
	queue_free()


func _set_spread(value: float) -> void:
	_spread = value
	queue_redraw()


func _draw() -> void:
	var wing := size.x * 0.5 * (1.0 - _spread)
	_draw_wing(wing - size.x * 0.5, size.x * 0.5, true)
	_draw_wing(size.x - wing, size.x * 0.5, false)
	if not _caption.is_empty():
		var opacity := 1.0 - smoothstep(0.02, 0.35, _spread)
		var plaque := Rect2(size.x * 0.5 - 195, size.y * 0.5 - 97, 390, 156)
		draw_rect(plaque, Color(0.94, 0.90, 0.80, opacity))
		draw_rect(plaque.grow(-7), Color(0.48, 0.32, 0.18, opacity), false, 1.0)
		var ink := DARK
		ink.a = opacity
		_draw_centered(_caption, size.y * 0.47, 69, ink)
		ink = Color(0.48, 0.16, 0.16, opacity)
		_draw_centered(_subtitle, size.y * 0.55, 26, ink)


func _draw_centered(text: String, baseline: float, font_size: int, color: Color) -> void:
	var width := _font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
	draw_string(_font, Vector2((size.x - width) * 0.5, baseline), text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, color)


func _draw_wing(x: float, width: float, left: bool) -> void:
	draw_rect(Rect2(x, 0, width, size.y), PAPER)
	for fiber in _grain:
		var start := Vector2(x + 13.0 + fiber.x * (width - 30.0), fiber.y * size.y)
		draw_line(start, start + Vector2(5.0 + 9.0 * fiber.y, -0.6), Color(0.32, 0.21, 0.13, 0.10), 1.0)
	for y in [size.y * 0.086, size.y * 0.914]:
		draw_line(Vector2(x, y), Vector2(x + width, y), GOLD, 1.0)
	var edge := x + width - 16.0 if left else x
	draw_rect(Rect2(edge, 0, 16, size.y), DARK)
	draw_rect(Rect2(edge + 2, 0, 3, size.y), GOLD)
	draw_rect(Rect2(edge + 9, 0, 3, size.y), Color("#504137"))
