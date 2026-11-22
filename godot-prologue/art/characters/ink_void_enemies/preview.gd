extends Node2D

@onready var character_picker: OptionButton = $Interface/Characters
@onready var action_picker: OptionButton = $Interface/Actions
@onready var stage: Node2D = $VisualStage

var catalog: Dictionary
var character_ids: Array[String] = []
var action_ids: Array[String] = []
var visual: Node2D
var player: AnimationPlayer

func _ready() -> void:
	var folder := scene_file_path.get_base_dir()
	catalog = JSON.parse_string(FileAccess.get_file_as_string(folder.path_join("manifest.json"))).characters
	for id in catalog:
		character_ids.append(id)
		character_picker.add_item(catalog[id].label)
	character_picker.item_selected.connect(_select_character)
	action_picker.item_selected.connect(_play_action)
	$Interface/Replay.pressed.connect(func(): _play_action(action_picker.selected))
	get_viewport().size_changed.connect(_layout_stage)
	_layout_stage()
	character_picker.select(0)
	_select_character(0)

func _select_character(index: int) -> void:
	if is_instance_valid(visual):
		stage.remove_child(visual)
		visual.queue_free()
	var info: Dictionary = catalog[character_ids[index]]
	var path := scene_file_path.get_base_dir().path_join(info.scene)
	var scene: PackedScene = load(path)
	visual = scene.instantiate()
	stage.add_child(visual)
	player = visual.get_node("AnimationPlayer")
	action_picker.clear()
	action_ids.clear()
	for id in info.clips:
		action_ids.append(id)
		action_picker.add_item(info.clips[id].label)
	var default_index := action_ids.find(info.default)
	action_picker.select(default_index)
	_play_action(default_index)

func _play_action(index: int) -> void:
	player.stop()
	player.play(action_ids[index])


func _layout_stage() -> void:
	stage.position = get_viewport_rect().size * Vector2(0.5, 0.80)
