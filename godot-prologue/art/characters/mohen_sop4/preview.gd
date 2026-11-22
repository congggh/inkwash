extends Node2D

@onready var character: Node2D = $MoHenVisual
@onready var player: AnimationPlayer = $MoHenVisual/AnimationPlayer
@onready var picker: OptionButton = $Interface/Actions/Moves

var clip_ids: Array[StringName] = []


func _ready() -> void:
	var manifest_path := scene_file_path.get_base_dir().path_join("manifest.json")
	var manifest: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(manifest_path))
	for animation: String in manifest["clips"]:
		clip_ids.append(StringName(animation))
		picker.add_item(manifest["clips"][animation]["label"])
	picker.select(clip_ids.find(&"idle"))
	picker.item_selected.connect(_play_choice)
	$Interface/Actions/Replay.pressed.connect(func(): _play_choice(picker.selected))
	$Interface/Actions/Back.pressed.connect(_back)
	get_viewport().size_changed.connect(_layout_character)
	_layout_character()


func _layout_character() -> void:
	character.position = get_viewport_rect().size * Vector2(0.5, 0.71)


func _play_choice(index: int) -> void:
	player.stop()
	player.play(clip_ids[index])


func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_back()


func _back() -> void:
	get_tree().change_scene_to_file("res://levels.tscn")
