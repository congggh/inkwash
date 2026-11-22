extends Control

signal retry_requested
signal title_requested

const PARCHMENT := Color("#efe4ce")
const RED := Color("#843436")
const GOLD := Color("#a28a62")

var _retry: Button
var _title: Button
var _leaving := false


func _ready() -> void:
	set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	var font := SystemFont.new()
	font.font_names = PackedStringArray(["STKaiti", "KaiTi", "Kaiti SC", "Noto Serif CJK SC", "Microsoft YaHei"])
	theme = Theme.new()
	theme.default_font = font
	theme.default_font_size = 23

	var shade := ColorRect.new()
	shade.color = Color(0.064, 0.049, 0.044, 0.78)
	shade.modulate.a = 0.0
	shade.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	add_child(shade)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	add_child(center)
	var panel := PanelContainer.new()
	panel.custom_minimum_size.x = 455
	panel.modulate.a = 0.0
	panel.add_theme_stylebox_override("panel", _box(Color("#26201d"), GOLD, 43, 30))
	center.add_child(panel)

	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 14)
	panel.add_child(column)
	column.add_child(_label("序章  /  断云台", 19, Color("#c5ae88")))
	column.add_child(_label("墨痕倒下", 57, PARCHMENT))
	column.add_child(_label("生命耗尽，本局结束。", 22, Color("#d7c7ad")))
	var rule := ColorRect.new()
	rule.color = Color("#6b5543")
	rule.custom_minimum_size.y = 1
	column.add_child(rule)
	_retry = _button(column, "重游序章    R", true, _retry_run)
	_title = _button(column, "返回题卷    Esc", false, _return_to_title)

	var reveal := create_tween().set_ignore_time_scale(true).set_parallel(true)
	reveal.tween_property(shade, "modulate:a", 1.0, 0.47)
	reveal.tween_property(panel, "modulate:a", 1.0, 0.36).set_delay(0.22)
	reveal.chain().tween_callback(_enable_buttons)


func _input(event: InputEvent) -> void:
	if event.is_echo():
		return
	if event.is_action_pressed("restart_level"):
		get_viewport().set_input_as_handled()
		_retry_run()
	elif event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_return_to_title()


func _enable_buttons() -> void:
	if _leaving:
		return
	_retry.disabled = false
	_title.disabled = false
	_retry.grab_focus()


func _retry_run() -> void:
	if not _leaving:
		_leaving = true
		retry_requested.emit()


func _return_to_title() -> void:
	if not _leaving:
		_leaving = true
		title_requested.emit()


func _button(parent: Control, text: String, primary: bool, command: Callable) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size.y = 48
	button.disabled = true
	button.mouse_default_cursor_shape = CURSOR_POINTING_HAND
	button.add_theme_stylebox_override("normal", _box(RED if primary else Color("#2b221e"), GOLD, 12, 5))
	button.add_theme_stylebox_override("hover", _box(Color("#a43f3b") if primary else Color("#503a30"), PARCHMENT, 12, 5))
	button.add_theme_stylebox_override("pressed", _box(Color("#372722"), GOLD, 12, 5))
	button.add_theme_stylebox_override("disabled", _box(RED if primary else Color("#2b221e"), GOLD, 12, 5))
	button.add_theme_stylebox_override("focus", _box(Color.TRANSPARENT, PARCHMENT, 12, 5))
	for state in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color", "font_disabled_color"]:
		button.add_theme_color_override(state, PARCHMENT)
	button.pressed.connect(command)
	parent.add_child(button)
	return button


func _label(text: String, size_px: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_color_override("font_color", color)
	label.add_theme_font_size_override("font_size", size_px)
	return label


func _box(fill: Color, border: Color, horizontal: int, vertical: int) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = fill
	box.border_color = border
	box.set_border_width_all(1)
	box.content_margin_left = horizontal
	box.content_margin_right = horizontal
	box.content_margin_top = vertical
	box.content_margin_bottom = vertical
	return box
