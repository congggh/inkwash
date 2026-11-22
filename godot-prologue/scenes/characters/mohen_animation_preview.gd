extends Node2D

const LIGHT := {
	&"attack": &"rising_cut",
	&"rising_cut": &"heavy_link",
	&"heavy_cut": &"rising_cut",
}
const HEAVY := {
	&"attack": &"heavy_cut",
	&"rising_cut": &"heavy_link",
}
const LINK_FRAMES := {
	&"attack": 6,
	&"rising_cut": 6,
	&"heavy_cut": 6,
}
const MOVE_NAMES := {
	&"attack": "横抹截江",
	&"rising_cut": "倒卷帘",
	&"heavy_cut": "枯笔断岳",
	&"heavy_link": "枯笔断岳",
}

const GROUND_Y := 625.0
const GRAVITY := 1250.0
const JUMP_SPEED := 440.0
const DOUBLE_JUMP_SPEED := 390.0
const JUMP_POSE_OFFSETS := [0.0, 0.0, 0.0, 26.0, 56.0, 28.0, 0.0, 0.0]
const INK_CUES := {
	&"attack": [3, &"sweep", Vector2(105, -170)],
	&"rising_cut": [3, &"rise", Vector2(100, -217)],
	&"heavy_cut": [4, &"cleave", Vector2(136, -147)],
	&"heavy_link": [3, &"cleave", Vector2(136, -147)],
}

@onready var ink: AnimatedSprite2D = $SwordInk
@onready var air_ink: AnimatedSprite2D = $AirInk
@onready var sprite: AnimatedSprite2D = $MoHen
@onready var combo_label: Label = $Combo

var combo_steps: PackedStringArray
var queued_key: StringName
var queued_animation: StringName
var airborne := false
var used_double_jump := false
var vertical_speed := 0.0

func _ready() -> void:
	$UI/Idle.pressed.connect(_play_movement.bind(&"idle"))
	$UI/Run.pressed.connect(_play_movement.bind(&"run"))
	$UI/Jump.pressed.connect(_jump)
	$UI/Light.pressed.connect(_attack.bind(&"J"))
	$UI/Heavy.pressed.connect(_attack.bind(&"I"))
	sprite.frame_changed.connect(_on_frame_changed)
	sprite.animation_finished.connect(_finish)
	ink.animation_finished.connect(ink.hide)
	air_ink.animation_finished.connect(air_ink.hide)

func _unhandled_key_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.is_pressed() or event.is_echo():
		return
	match event.physical_keycode:
		KEY_J:
			_attack(&"J")
		KEY_I:
			_attack(&"I")
		KEY_SPACE:
			_jump()
		_:
			return
	get_viewport().set_input_as_handled()

func _attack(key: StringName) -> void:
	if airborne:
		return
	if not MOVE_NAMES.has(sprite.animation):
		combo_steps.clear()
		_start_attack(key, &"attack" if key == &"J" else &"heavy_cut")
		return

	var next: StringName = (LIGHT if key == &"J" else HEAVY).get(sprite.animation, &"")
	if next.is_empty() or not queued_animation.is_empty() or combo_steps.size() >= 3:
		return
	if sprite.frame > LINK_FRAMES[sprite.animation]:
		return
	queued_key = key
	queued_animation = next
	_try_link()

func _on_frame_changed() -> void:
	var cue: Array = INK_CUES.get(sprite.animation, [])
	if not cue.is_empty() and sprite.frame == cue[0]:
		_show_ink(ink, cue[1], sprite.position + cue[2])
	_try_link()

func _show_ink(effect: AnimatedSprite2D, animation: StringName, at: Vector2) -> void:
	effect.position = at
	effect.stop()
	effect.show()
	effect.play(animation)

func _try_link() -> void:
	if queued_animation.is_empty() or sprite.frame < LINK_FRAMES[sprite.animation]:
		return
	var key := queued_key
	var next := queued_animation
	queued_key = &""
	queued_animation = &""
	_start_attack(key, next, 1 if sprite.animation == &"attack" and next == &"heavy_cut" else 0)

func _start_attack(key: StringName, animation: StringName, start_frame := 0) -> void:
	combo_steps.append("%s %s" % [key, MOVE_NAMES[animation]])
	combo_label.text = "  →  ".join(combo_steps)
	_play(animation)
	sprite.frame = start_frame

func _finish() -> void:
	if airborne:
		return
	queued_animation = &""
	queued_key = &""
	_play(&"idle")

func _jump() -> void:
	if airborne:
		if used_double_jump:
			return
		used_double_jump = true
		vertical_speed = -DOUBLE_JUMP_SPEED
		_show_ink(air_ink, &"air", sprite.position + Vector2(-10, -54))
		sprite.offset.y = -500
		_play(&"double_jump")
		combo_label.text = "二段跳"
		return

	_play_movement(&"jump")
	airborne = true
	vertical_speed = -JUMP_SPEED
	sprite.pause()
	sprite.frame = 2
	combo_label.text = "一段跳 · 空中再按空格"

func _physics_process(delta: float) -> void:
	if not airborne:
		return
	sprite.position.y += (vertical_speed + 0.5 * GRAVITY * delta) * delta
	vertical_speed += GRAVITY * delta
	if sprite.position.y >= GROUND_Y:
		airborne = false
		used_double_jump = false
		sprite.position.y = GROUND_Y
		sprite.offset.y = -500
		combo_label.text = ""
		_play(&"jump")
		sprite.frame = 6
	elif not used_double_jump:
		var pose := 5
		if vertical_speed < -230.0:
			pose = 2
		elif vertical_speed < -65.0:
			pose = 3
		elif vertical_speed < 95.0:
			pose = 4
		sprite.frame = pose
		sprite.offset.y = -500 + JUMP_POSE_OFFSETS[pose]

func _play_movement(animation: StringName) -> void:
	airborne = false
	used_double_jump = false
	sprite.position.y = GROUND_Y
	sprite.offset.y = -500
	ink.hide()
	air_ink.hide()
	combo_steps.clear()
	combo_label.text = ""
	queued_animation = &""
	queued_key = &""
	_play(animation)

func _play(animation: StringName) -> void:
	sprite.stop()
	sprite.play(animation)




