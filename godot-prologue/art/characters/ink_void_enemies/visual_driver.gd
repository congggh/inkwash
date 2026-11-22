extends Node2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var animation: AnimationPlayer = $AnimationPlayer

var _pose_start := 0.0


func face(direction: float) -> void:
	sprite.flip_h = direction < 0.0


func play_pose(clip: StringName, start := 0.0) -> void:
	if animation.assigned_animation == clip and is_equal_approx(_pose_start, start):
		return
	_pose_start = start
	animation.stop()
	animation.play(clip)
	animation.seek(start, true)
