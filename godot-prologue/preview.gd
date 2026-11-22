extends MarginContainer

@export var show_play_button := true

@onready var picker: OptionButton = %Picker
@onready var layer: Button = %Layer
@onready var fit: Button = %Fit
@onready var scroll: ScrollContainer = %Scroll
@onready var canvas: Control = %Canvas
@onready var status: Label = %Status

var entries: Array
var stage: Node2D
var image_size := Vector2.ZERO


func _ready() -> void:
	%Sequence.pressed.connect(func() -> void: get_tree().change_scene_to_file("res://prologue_playback.tscn"))
	if not show_play_button:
		%Play.hide()
	else:
		%Play.pressed.connect(func() -> void: get_tree().change_scene_to_file("res://levels.tscn"))
	picker.item_selected.connect(_show_scene)
	layer.toggled.connect(_show_layer)
	fit.toggled.connect(func(_enabled: bool) -> void: _layout_stage())
	scroll.resized.connect(_layout_stage)
	canvas.resized.connect(_center_stage)
	entries = JSON.parse_string(FileAccess.get_file_as_string("res://catalog.json"))
	for entry in entries:
		picker.add_item(entry["title"])
	_show_scene(0)


func _unhandled_key_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or picker.get_popup().visible:
		return
	match event.keycode:
		KEY_ESCAPE:
			get_tree().change_scene_to_file(PlayerLedger.TITLE)
		KEY_LEFT:
			_show_scene(picker.selected - 1)
		KEY_RIGHT:
			_show_scene(picker.selected + 1)
		KEY_TAB:
			if not layer.disabled and not event.echo:
				layer.button_pressed = not layer.button_pressed
		_:
			return
	get_viewport().set_input_as_handled()


func _show_scene(index: int) -> void:
	if index < 0 or index >= entries.size():
		return

	var scene := load(entries[index]["scene"]) as PackedScene
	if stage != null:
		stage.free()
	stage = scene.instantiate() as Node2D
	canvas.add_child(stage)
	picker.select(index)
	_show_layer(layer.button_pressed)
	scroll.set_deferred("scroll_horizontal", 0)


func _show_layer(show_inner: bool) -> void:
	var surface := stage.get_node("Surface") as Node2D
	var inner := stage.get_node_or_null("Inner") as Node2D
	var active := surface
	if inner != null:
		inner.visible = show_inner
		surface.visible = not show_inner
		if show_inner:
			active = inner
	layer.disabled = inner == null
	if layer.disabled:
		layer.text = "单层图"
	else:
		layer.text = "里层 · 白描" if show_inner else "表层 · 浓墨"
	image_size = active.get_meta("image_size")
	_layout_stage()


func _layout_stage() -> void:
	if stage == null or scroll.size.x <= 0.0 or scroll.size.y <= 0.0:
		return

	var available := scroll.size
	var bar_height := scroll.get_h_scroll_bar().get_combined_minimum_size().y
	var horizontal_scroll := image_size.x / image_size.y > available.x / available.y
	fit.visible = horizontal_scroll and image_size.x / image_size.y > 3.0
	fit.text = "展开长卷" if fit.button_pressed else "显示全图"
	var scale_factor := minf(available.x / image_size.x, available.y / image_size.y)
	if fit.visible and not fit.button_pressed:
		scale_factor = maxf(1.0, available.y - bar_height) / image_size.y
	stage.scale = Vector2.ONE * scale_factor
	canvas.custom_minimum_size = Vector2(ceilf(image_size.x * scale_factor), 0.0)
	_center_stage()
	status.text = "%02d / %02d" % [picker.selected + 1, entries.size()]


func _center_stage() -> void:
	if stage != null:
		stage.position = ((canvas.size - image_size * stage.scale) * 0.5).max(Vector2.ZERO).floor()
