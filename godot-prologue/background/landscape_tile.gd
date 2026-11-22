extends Node2D

const WeatherShader := preload("res://background/landscape.gdshader")
const StelePlate := preload("res://art/levels/surface_07_parallax_clean.png")
const FoundryPlate := preload("res://art/levels/surface_03_armillary_clean.png")
const SwordPlate := preload("res://art/levels/surface_03_swords_clean.png")
const PhoenixPlate := preload("res://art/levels/surface_05_phoenix_clean.png")
const PhoenixArt := preload("res://art/levels/phoenix_flight.png")
const STELE_OUTLINES := [
	[
		Vector2(0, 132), Vector2(99, 58), Vector2(205, 0), Vector2(451, 0),
		Vector2(428, 102), Vector2(456, 139), Vector2(456, 299), Vector2(449, 383),
		Vector2(490, 409), Vector2(429, 477), Vector2(0, 477),
	],
	[
		Vector2(403, 477), Vector2(435, 420), Vector2(468, 393), Vector2(527, 213),
		Vector2(570, 195), Vector2(606, 194), Vector2(620, 170), Vector2(658, 159),
		Vector2(718, 183), Vector2(735, 236), Vector2(775, 248), Vector2(799, 217),
		Vector2(850, 194), Vector2(899, 185), Vector2(905, 214), Vector2(887, 275),
		Vector2(966, 254), Vector2(981, 230), Vector2(991, 238), Vector2(949, 353),
		Vector2(968, 343), Vector2(1038, 319), Vector2(1078, 306), Vector2(1089, 323),
		Vector2(1052, 476),
	],
]

var painting := Sprite2D.new()
var effect := ShaderMaterial.new()
var stele_cutouts: Array[Polygon2D] = []


func setup(panel: int, bank_y: float, is_stele: bool) -> void:
	painting.name = "Painting"
	painting.centered = false
	effect.shader = WeatherShader
	effect.set_shader_parameter(&"panel", panel)
	effect.set_shader_parameter(&"bank_y", 477.0 if is_stele else bank_y)
	effect.set_shader_parameter(&"tile_x", position.x)
	painting.material = effect
	add_child(painting)
	if panel == 3:
		effect.set_shader_parameter(&"foundry_plate", FoundryPlate)
		effect.set_shader_parameter(&"sword_plate", SwordPlate)
	elif panel == 5:
		effect.set_shader_parameter(&"phoenix_plate", PhoenixPlate)
		effect.set_shader_parameter(&"phoenix_art", PhoenixArt)
	if is_stele:
		effect.set_shader_parameter(&"clean_plate", StelePlate)
		for outline in STELE_OUTLINES:
			var cutout := Polygon2D.new()
			cutout.polygon = PackedVector2Array(outline)
			cutout.uv = cutout.polygon
			var edge_material := ShaderMaterial.new()
			edge_material.shader = WeatherShader
			edge_material.set_shader_parameter(&"stele_foreground", true)
			edge_material.set_shader_parameter(&"outline_size", cutout.polygon.size())
			var points := cutout.polygon
			points.resize(24)
			edge_material.set_shader_parameter(&"outline", points)
			cutout.material = edge_material
			stele_cutouts.append(cutout)
			add_child(cutout)


func set_track(art: Texture2D, previous: Texture2D, following: Texture2D, inner: bool) -> void:
	painting.texture = art
	effect.set_shader_parameter(&"source_art", art)
	effect.set_shader_parameter(&"inner_track", inner)
	effect.set_shader_parameter(&"has_previous", previous != null)
	effect.set_shader_parameter(&"has_following", following != null)
	effect.set_shader_parameter(&"previous_art", previous)
	effect.set_shader_parameter(&"following_art", following)
	effect.set_shader_parameter(&"use_clean_plate", not inner and not stele_cutouts.is_empty())
	for cutout in stele_cutouts:
		cutout.texture = art
		var material := cutout.material as ShaderMaterial
		material.set_shader_parameter(&"source_art", art)
		cutout.visible = not inner


func update_view(camera_x: float, sunlight: Vector2, player_x: float, storm_age: float,
		foreground_motion: float, gravel_age: Vector2) -> void:
	effect.set_shader_parameter(&"camera_x", camera_x)
	effect.set_shader_parameter(&"sunlight", sunlight)
	effect.set_shader_parameter(&"player_local", player_x - position.x)
	effect.set_shader_parameter(&"storm_age", storm_age)
	effect.set_shader_parameter(&"foreground_motion", foreground_motion)
	effect.set_shader_parameter(&"gravel_age", gravel_age)
	for cutout in stele_cutouts:
		var material := cutout.material as ShaderMaterial
		material.set_shader_parameter(&"player_local", player_x - position.x)


func update_ink(origin: Vector2, radius: float, stains: PackedVector3Array) -> void:
	effect.set_shader_parameter(&"ink_origin", origin)
	effect.set_shader_parameter(&"ink_radius", radius)
	effect.set_shader_parameter(&"ink_stains", stains)
