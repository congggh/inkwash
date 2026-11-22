extends Control

var current := 100
var trailing := 100.0
var maximum := 100


func update_health(value: int, limit: int, delta: float) -> void:
	current = value
	maximum = limit
	trailing = 0.0 if current <= 0 else maxf(float(current), move_toward(trailing, float(current), delta * 48.0))
	queue_redraw()


func _draw() -> void:
	var font := ThemeDB.fallback_font
	var paper := Color("#e5d2ae")
	var ink := Color("#252027")
	draw_colored_polygon(PackedVector2Array([
		Vector2(-7, 23), Vector2(9, 14), Vector2(221, 17), Vector2(241, 28),
		Vector2(229, 39), Vector2(12, 42),
	]), paper)
	draw_rect(Rect2(8, 23, 219, 12), Color("#b2a08a"))
	draw_rect(Rect2(8, 23, 219.0 * trailing / maximum, 12), Color("#9d4e43"))
	var width := 219.0 * current / maximum
	if width > 0.0:
		draw_colored_polygon(PackedVector2Array([
			Vector2(8, 23), Vector2(8 + width, 23), Vector2(8 + width - minf(width, 7.0), 35), Vector2(8, 35)
		]), ink)
	draw_string_outline(font, Vector2(1, 9), "墨痕", HORIZONTAL_ALIGNMENT_LEFT, -1, 20, 5, ink)
	draw_string(font, Vector2(1, 9), "墨痕", HORIZONTAL_ALIGNMENT_LEFT, -1, 20, paper)
	var label := "%d / %d" % [current, maximum]
	draw_string_outline(font, Vector2(159, 9), label, HORIZONTAL_ALIGNMENT_LEFT, -1, 17, 5, ink)
	draw_string(font, Vector2(159, 9), label, HORIZONTAL_ALIGNMENT_LEFT, -1, 17, paper)
