extends Control

const INK := Color("#242322")
const PAPER := Color("#efe9da")
const MUTED := Color("#665d52")
const RED := Color("#952e2d")
const RULE := Color("#c3b69d")
const GOLD := Color("#d0b17c")
const ART := preload("res://art/levels/surface_10.jpg")
const ScrollReveal := preload("res://scroll_reveal.gd")

enum Page { TITLE, PLAYERS, RANKING }

var _page := Page.TITLE
var _body: VBoxContainer
var _name_input: LineEdit
var _status: Label
static var _shown_title_reveal := false


func _ready() -> void:
	ScoreAudio.music(ScoreAudio.Track.TITLE)
	var serif := SystemFont.new()
	serif.font_names = PackedStringArray(["STKaiti", "KaiTi", "Kaiti SC", "Noto Serif CJK SC", "Microsoft YaHei"])
	theme = Theme.new()
	theme.default_font = serif
	theme.default_font_size = 22
	theme.set_color("font_color", "Label", INK)
	theme.set_color("font_color", "LineEdit", INK)
	theme.set_color("font_placeholder_color", "LineEdit", MUTED)
	theme.set_color("caret_color", "LineEdit", INK)
	theme.set_stylebox("normal", "LineEdit", _box(Color("#f9f4e7"), RULE))
	theme.set_stylebox("focus", "LineEdit", _box(Color.TRANSPARENT, RED))
	_build_scroll()
	if PlayerLedger.open_results:
		PlayerLedger.open_results = false
		_show_ranking()
	else:
		_show_title()
		if not _shown_title_reveal:
			_shown_title_reveal = true
			var scroll := ScrollReveal.new()
			add_child(scroll)
			scroll.reveal()


func _build_scroll() -> void:
	var backdrop := ColorRect.new()
	backdrop.color = INK
	backdrop.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	add_child(backdrop)

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 28)
	add_child(margin)

	var frame := PanelContainer.new()
	var frame_style := _box(Color("#29231f"), GOLD)
	for side in [SIDE_LEFT, SIDE_RIGHT, SIDE_TOP, SIDE_BOTTOM]:
		frame_style.set_content_margin(side, 9)
	frame.add_theme_stylebox_override("panel", frame_style)
	margin.add_child(frame)

	var spread := HBoxContainer.new()
	spread.add_theme_constant_override("separation", 0)
	frame.add_child(spread)

	var paper := PanelContainer.new()
	paper.custom_minimum_size.x = 486
	paper.add_theme_stylebox_override("panel", _box(PAPER, RULE))
	spread.add_child(paper)
	var inset := MarginContainer.new()
	inset.add_theme_constant_override("margin_left", 39)
	inset.add_theme_constant_override("margin_right", 39)
	inset.add_theme_constant_override("margin_top", 30)
	inset.add_theme_constant_override("margin_bottom", 28)
	paper.add_child(inset)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 16)
	inset.add_child(column)
	column.add_child(_label("留 白   /   INK & VOID", 20, RED))
	column.add_child(_rule())
	_body = VBoxContainer.new()
	_body.size_flags_vertical = SIZE_EXPAND_FILL
	_body.add_theme_constant_override("separation", 12)
	column.add_child(_body)
	column.add_child(_rule())
	column.add_child(_label("序章    /    断云台", 18, MUTED))

	var art := TextureRect.new()
	art.texture = ART
	art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	art.size_flags_horizontal = SIZE_EXPAND_FILL
	art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	spread.add_child(art)

	var caption := PanelContainer.new()
	var caption_style := _box(Color("#201b18"), GOLD)
	caption_style.content_margin_left = 24
	caption_style.content_margin_right = 24
	caption_style.content_margin_top = 8
	caption_style.content_margin_bottom = 8
	caption.add_theme_stylebox_override("panel", caption_style)
	art.add_child(caption)
	caption.set_anchors_and_offsets_preset(PRESET_BOTTOM_LEFT)
	caption.offset_left = 28
	caption.offset_top = -79
	caption.offset_bottom = -25
	caption.add_child(_label("断云台 · 残照", 23, PAPER))


func _open(page: Page) -> void:
	_page = page
	for child in _body.get_children():
		_body.remove_child(child)
		child.queue_free()


func _show_title() -> void:
	_open(Page.TITLE)
	_spacer(_body, true)
	_body.add_child(_label("留白", 100))
	var player := PlayerLedger.player_name(PlayerLedger.active_player)
	var player_label := _label("本地玩家  /  " + (player if not player.is_empty() else "尚未落款"), 21, MUTED)
	player_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	_body.add_child(player_label)
	_spacer(_body)
	var play := _button(_body, "入画  ·  开始序章", _play, true)
	_button(_body, "落款  ·  玩家登录" if player.is_empty() else "落款  ·  切换玩家", _show_players)
	_button(_body, "战绩榜", _show_ranking)
	_button(_body, "画谱  ·  场景预览", func() -> void:
		get_tree().change_scene_to_file("res://preview.tscn")
	)
	_button(_body, "掩卷  ·  退出游戏", func() -> void: get_tree().quit())
	_spacer(_body, true)
	play.grab_focus()


func _show_players() -> void:
	_open(Page.PLAYERS)
	_spacer(_body)
	_body.add_child(_label("玩家落款", 56))
	_body.add_child(_label("输入昵称以创建或进入本地档案。", 20, MUTED))
	_name_input = LineEdit.new()
	_name_input.max_length = 16
	_name_input.placeholder_text = "玩家昵称"
	_name_input.custom_minimum_size.y = 54
	_name_input.text_submitted.connect(func(_value: String) -> void: _sign_in())
	_body.add_child(_name_input)
	_button(_body, "确认落款", _sign_in, true)

	var names := PlayerLedger.player_names()
	if not names.is_empty():
		var profiles := OptionButton.new()
		profiles.fit_to_longest_item = false
		profiles.clip_text = true
		profiles.add_item("选择已有档案")
		profiles.set_item_disabled(0, true)
		for name in names:
			profiles.add_item(name)
		profiles.custom_minimum_size.y = 46
		profiles.add_theme_color_override("font_color", INK)
		profiles.add_theme_stylebox_override("normal", _box(Color("#e7decb"), RULE))
		profiles.add_theme_stylebox_override("hover", _box(Color("#f9f4e7"), RED))
		profiles.add_theme_color_override("font_hover_color", INK)
		profiles.item_selected.connect(func(index: int) -> void:
			_name_input.text = profiles.get_item_text(index)
		)
		_body.add_child(profiles)

	_status = _label("", 19, RED)
	_status.custom_minimum_size.y = 32
	_body.add_child(_status)
	_spacer(_body, true)
	_button(_body, "返回题卷", _show_title)
	_name_input.grab_focus()


func _sign_in() -> void:
	var error := PlayerLedger.sign_in(_name_input.text)
	if error == ERR_INVALID_PARAMETER:
		_status.text = "请输入 1–16 个字符的有效昵称。"
	elif error != OK:
		_status.text = "无法读取或保存玩家档案。"
	else:
		_show_title()


func _show_ranking() -> void:
	_open(Page.RANKING)
	_body.add_child(_label("序章战绩榜", 48))
	_body.add_child(_label("本地排行  /  每位玩家的最佳成绩", 19, MUTED))
	if not PlayerLedger.last_run.is_empty():
		var run := PlayerLedger.last_run
		var note := "本局  %d 分   ·   %s" % [run.score, PlayerLedger.format_time(run.time)]
		if not run.saved:
			note += "   ·   保存失败"
		_body.add_child(_label(note, 21, RED))
	_body.add_child(_row(["名次", "玩家", "积分", "用时"], MUTED, 17))
	_body.add_child(_rule())
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_body.add_child(scroll)
	var entries := VBoxContainer.new()
	entries.size_flags_horizontal = SIZE_EXPAND_FILL
	scroll.add_child(entries)
	var ranking := PlayerLedger.leaderboard()
	if ranking.is_empty():
		entries.add_child(_label("通关序章后，战绩将在这里落款。", 19, MUTED))
	var place := 0
	for index in ranking.size():
		var entry := ranking[index]
		if index == 0 or entry.score != ranking[index - 1].score or entry.time != ranking[index - 1].time:
			place = index + 1
		var color := RED if entry.id == PlayerLedger.active_player else INK
		entries.add_child(_row([str(place), entry.name, str(entry.score), PlayerLedger.format_time(entry.time)], color, 19))
		entries.add_child(_rule())
	_body.add_child(_label("通关分 + 剩余生命奖励 + 用时奖励", 17, MUTED))
	_button(_body, "返回题卷", _show_title).grab_focus()


func _play() -> void:
	if PlayerLedger.active_player.is_empty():
		_show_players()
	else:
		get_tree().change_scene_to_file("res://levels.tscn")


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and _page != Page.TITLE:
		_show_title()
		get_viewport().set_input_as_handled()


func _row(values: Array[String], color: Color, font_size: int) -> HBoxContainer:
	var line := HBoxContainer.new()
	line.custom_minimum_size.y = 37
	var widths := [53, 0, 65, 99]
	for index in values.size():
		var cell := _label(values[index], font_size, color)
		cell.custom_minimum_size.x = widths[index]
		cell.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		if index == 1:
			cell.size_flags_horizontal = SIZE_EXPAND_FILL
		elif index >= 2:
			cell.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		line.add_child(cell)
	return line


func _button(parent: Control, caption: String, action: Callable, primary := false) -> Button:
	var button := Button.new()
	button.text = caption
	button.custom_minimum_size.y = 49
	button.mouse_default_cursor_shape = CURSOR_POINTING_HAND
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	button.add_theme_stylebox_override("normal", _box(RED if primary else PAPER, RED if primary else RULE))
	button.add_theme_stylebox_override("hover", _box(Color("#79302b") if primary else Color("#e6d9bf"), RED))
	button.add_theme_stylebox_override("pressed", _box(INK, GOLD))
	button.add_theme_stylebox_override("focus", _box(Color.TRANSPARENT, GOLD if primary else RED))
	button.add_theme_color_override("font_color", PAPER if primary else INK)
	button.add_theme_color_override("font_hover_color", PAPER if primary else RED)
	button.add_theme_color_override("font_focus_color", PAPER if primary else RED)
	button.add_theme_color_override("font_pressed_color", PAPER)
	button.pressed.connect(action)
	parent.add_child(button)
	return button


func _label(caption: String, font_size: int, color := INK) -> Label:
	var label := Label.new()
	label.text = caption
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	return label


func _rule() -> ColorRect:
	var rule := ColorRect.new()
	rule.color = RULE
	rule.custom_minimum_size.y = 1
	rule.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return rule


func _spacer(parent: Control, expand := false) -> void:
	var spacer := Control.new()
	spacer.custom_minimum_size.y = 8
	if expand:
		spacer.size_flags_vertical = SIZE_EXPAND_FILL
	parent.add_child(spacer)


func _box(fill: Color, border: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(1)
	style.content_margin_left = 16
	style.content_margin_right = 16
	return style
