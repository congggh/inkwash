shader_type canvas_item;
render_mode unshaded;

uniform sampler2D white_art : source_color, filter_linear, repeat_disable;
uniform vec2 ink_origin;
uniform float ink_radius;
uniform vec3 ink_stains[16];
uniform sampler2D source_art : source_color, filter_linear, repeat_disable;
uniform sampler2D previous_art : source_color, filter_linear, repeat_disable;
uniform sampler2D following_art : source_color, filter_linear, repeat_disable;
uniform sampler2D clean_plate : source_color, filter_linear, repeat_disable;
uniform sampler2D foundry_plate : source_color, filter_linear, repeat_disable;
uniform sampler2D sword_plate : source_color, filter_linear, repeat_disable;
uniform sampler2D phoenix_plate : source_color, filter_linear, repeat_disable;
uniform sampler2D phoenix_art : source_color, filter_linear, repeat_disable;
uniform bool use_clean_plate = false;
uniform bool inner_track = false;
uniform bool has_previous = false;
uniform bool has_following = false;
uniform bool stele_foreground = false;
uniform int outline_size = 0;
uniform vec2 outline[24];
uniform float camera_x;
uniform float tile_x;
uniform float bank_y;
uniform vec2 sunlight;
uniform int panel;
uniform float player_local;
uniform float storm_age = -1.0;
uniform float foreground_motion = 0.0;
uniform vec2 gravel_age = vec2(-1.0);

const vec2 ART = vec2(1914.0, 822.0);

float hash_cell(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float cloud_noise(vec2 p) {
	vec2 cell = floor(p);
	vec2 f = fract(p);
	vec2 blend = f * f * (3.0 - 2.0 * f);
	return mix(
		mix(hash_cell(cell), hash_cell(cell + vec2(1.0, 0.0)), blend.x),
		mix(hash_cell(cell + vec2(0.0, 1.0)), hash_cell(cell + vec2(1.0, 1.0)), blend.x),
		blend.y
	);
}

float soft_region(vec2 p, vec2 center, vec2 radius) {
	vec2 distance = (p - center) / radius;
	return 1.0 - smoothstep(0.28, 1.0, dot(distance, distance));
}

vec3 read_art(sampler2D art, vec2 point) {
	if (point.x < 0.0 && has_previous) {
		return texture(previous_art, (point + vec2(ART.x, 0.0)) / ART).rgb;
	}
	if (point.x >= ART.x && has_following) {
		return texture(following_art, (point - vec2(ART.x, 0.0)) / ART).rgb;
	}
	vec2 uv = clamp(point / ART, vec2(0.0), vec2(1.0));
	vec3 color = texture(art, uv).rgb;
	if (use_clean_plate && point.y < bank_y) {
		float fill = 1.0 - smoothstep(1040.0, 1230.0, point.x);
		color = mix(color, texture(clean_plate, uv).rgb, fill);
	}
	return color;
}

#include "res://background/location_effects.gdshaderinc"
#include "res://background/moving_props.gdshaderinc"
#include "res://background/ambient_props.gdshaderinc"
#include "res://background/scene_details.gdshaderinc"
#include "res://background/foreground_current.gdshaderinc"

float feather_outline(vec2 p) {
	float nearest = 10000.0;
	for (int i = 0; i < outline_size; i++) {
		vec2 start = outline[i];
		vec2 end = outline[(i + 1) % outline_size];
		// Keep the cutouts flush against the canvas edge and the bridge.
		if ((start.y <= 0.0 && end.y <= 0.0) || (start.x <= 0.0 && end.x <= 0.0)
			|| (start.y >= 474.0 && end.y >= 474.0)) {
			continue;
		}
		vec2 edge = end - start;
		float along = clamp(dot(p - start, edge) / dot(edge, edge), 0.0, 1.0);
		nearest = min(nearest, length(p - start - along * edge));
	}
	return smoothstep(0.0, 5.0, nearest);
}

vec3 landscape_color(sampler2D art, vec3 color, vec2 original) {
	vec2 point = original;
	float world_x = tile_x + original.x;
	float offset = clamp((camera_x - world_x) * 0.23, -167.0, 167.0);
	if (!has_previous) {
		offset *= smoothstep(0.0, 510.0, original.x);
	}
	if (!has_following) {
		offset *= smoothstep(0.0, 510.0, ART.x - original.x);
	}
	// Keep the painted walking surface registered with the gameplay floor.
	float hills = 1.0 - smoothstep(bank_y - 65.0, bank_y, original.y);
	if (use_clean_plate) {
		hills = mix(hills, 1.0 - smoothstep(bank_y - 3.0, bank_y, original.y),
			1.0 - smoothstep(1040.0, 1230.0, original.x));
	}
	point.x -= offset;
	if (hills > 0.0) {
		vec3 distant = read_art(art, point);
		int painted_panel = panel + (point.x < 0.0 && has_previous ? -1
			: (point.x >= ART.x && has_following ? 1 : 0));
		float painted_x = point.x + float(panel - painted_panel) * ART.x;
		vec2 local = vec2(clamp(painted_x, 0.0, ART.x), point.y);
		if (!inner_track && painted_panel == panel) {
			if (panel == 2) {
				distant = swing_plaque(art, distant, local);
			} else if (panel == 3) {
				distant = running_lava(art, distant, local, false);
				distant = forge_heat(art, distant, local);
				distant = spinning_armillary(distant, local);
				distant = falling_swords(art, distant, local);
				distant = forge_embers(distant, local);
			} else if (panel == 4) {
				distant = turn_winch(art, distant, local);
				distant = moving_winch_lines(art, distant, local);
				distant = stone_dragon_stream(distant, local);
			} else if (panel == 5) {
				distant = swinging_ink_bucket(art, distant, local, 803.0, 0.0);
				distant = swinging_ink_bucket(art, distant, local, 1362.0, 1.7);
				distant = maple_flag(art, distant, local);
				distant = flying_phoenix(distant, local);
				distant = falling_maple_leaves(distant, local);
			}
		}
		distant = animate_water(art, distant, point, local, painted_panel);
		distant = animate_sky(distant, local, vec2(point.x + tile_x, point.y), painted_panel);
		if (!inner_track && (painted_panel == 1 || painted_panel == 2)) {
			distant = reveal_sunlight(distant, local, painted_panel == 1 ? sunlight.x : sunlight.y, painted_panel == 2);
		}
		color = mix(color, distant, hills);
	}
	if (!inner_track && panel == 3) {
		if (original.y > 615.0) {
			color = running_lava(art, color, original, true);
		}
		color = forge_reflected_light(color, original);
	} else if (!inner_track && panel == 4) {
		color = winch_ink_splash(color, vec2(point.x, original.y));
	} else if (!inner_track && panel == 5 && original.y > 555.0) {
		color = foreground_current(art, color, original);
		color = falling_gravel(color, original, vec2(310.0, 638.0), gravel_age.x, 1.0);
		color = falling_gravel(color, original, vec2(1675.0, 620.0), gravel_age.y, -1.0);
	} else if (!inner_track && panel == 8) {
		color = storm_light(color, original);
	}
	if (!inner_track && (panel == 1 || panel == 2) && original.y >= bank_y) {
		vec2 wet_floor = vec2(panel == 1 ? 1556.0 : 1010.0, bank_y + 33.0);
		float reflection = soft_region(original, wet_floor, vec2(265.0, 35.0));
		color += (panel == 1 ? sunlight.x : sunlight.y) * reflection * color.r * vec3(0.24, 0.13, 0.05);
	}
	return drifting_mist(color, original, world_x - offset, bank_y, panel);
}

void fragment() {
	vec2 original = UV * ART;
	if (stele_foreground) {
		vec3 color = animate_water(source_art, COLOR.rgb, original, original, 13);
		color = stele_surface(color, original);
		COLOR = vec4(color, COLOR.a * feather_outline(original));
	} else {
		vec3 painted = landscape_color(source_art, COLOR.rgb, original);
		vec2 world = vec2(original.x + tile_x, original.y);
		float grain = cloud_noise(world * 0.045) * 24.0;
		float reveal = 0.0;
		if (ink_radius > 0.0) {
			reveal = 1.0 - smoothstep(ink_radius - 90.0, ink_radius, distance(world, ink_origin) + grain);
		}
		for (int i = 0; i < 16; i++) {
			vec3 stain = ink_stains[i];
			if (stain.z > 0.0 && abs(world.x - stain.x) < stain.z) {
				reveal = max(reveal, 1.0 - smoothstep(stain.z * 0.48, stain.z, distance(world, stain.xy) + grain * 0.44));
			}
		}
		vec3 paper = texture(white_art, UV).rgb;
		COLOR = vec4(mix(painted, paper, reveal), 1.0);
	}
}
