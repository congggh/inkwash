vec2 rotate_point(vec2 point, float angle) {
	float c = cos(angle);
	float s = sin(angle);
	return vec2(c * point.x - s * point.y, s * point.x + c * point.y);
}

vec3 swing_plaque(sampler2D art, vec3 color, vec2 p) {
	// The wall and upper chain anchors stay pinned while the plaque and tassels swing.
	float reach = (1.0 - smoothstep(108.0, 190.0, abs(p.x - 495.0)))
		* smoothstep(0.0, 105.0, p.y) * (1.0 - smoothstep(432.0, 494.0, p.y));
	if (reach <= 0.0) {
		return color;
	}
	vec2 hanger = vec2(493.0, 103.0);
	float sway = sin(TIME * 1.75) * 0.112 + sin(TIME * 3.10) * 0.009;
	vec2 sample_point = hanger + rotate_point(p - hanger, -sway * reach);
	return texture(art, sample_point / ART).rgb;
}

vec3 turning_gear(sampler2D art, vec3 color, vec2 p, vec2 axle, vec2 radius, bool right) {
	vec2 wheel = (p - axle) / radius;
	float r = length(wheel);
	float rim = 1.0 - smoothstep(0.95, 1.085, r);
	float shaft_side = right ? axle.x - p.x : p.x - axle.x;
	float supports = (1.0 - smoothstep(51.0, 83.0, shaft_side));
	float shaft = smoothstep(21.0, 36.0, shaft_side)
		* (1.0 - smoothstep(13.0, 24.0, abs(p.y - axle.y)));
	float mask = rim * supports * (1.0 - shaft) * smoothstep(0.16, 0.27, r);
	if (mask < 0.002) {
		return color;
	}
	// Reuse the visible half of the painted rim where the source extends above the canvas or behind the shaft.
	vec2 spun = rotate_point(wheel, -TIME * 0.54);
	float top = (2.0 - axle.y) / radius.y;
	spun.y = top + abs(spun.y - top);
	float inward = right ? -1.0 : 1.0;
	float edge = 48.0 / radius.x;
	spun.x = inward * (edge - abs(edge - spun.x * inward));
	vec3 metal = texture(art, (axle + spun * radius) / ART).rgb;
	return mix(color, metal, mask);
}

vec3 turn_winch(sampler2D art, vec3 color, vec2 p) {
	vec2 left_axle = vec2(571.0, 50.0);
	vec2 right_axle = vec2(1316.0, 62.0);
	if (p.x < 800.0) {
		return turning_gear(art, color, p, left_axle, vec2(116.0, 117.0), false);
	}
	return turning_gear(art, color, p, right_axle, vec2(123.0, 120.0), true);
}

vec3 spin_axis(vec3 v, float angle) {
	vec2 spin = rotate_point(v.xz, angle);
	return vec3(spin.x, v.y, spin.y);
}

// Solve the point where each viewing ray meets a ring's plane, then shade its metal band.
vec4 bronze_ring(vec2 p, vec3 normal, float radius, float width, float phase) {
	float nz = abs(normal.z) < 0.045 ? (normal.z < 0.0 ? -0.045 : 0.045) : normal.z;
	float depth = -dot(normal.xy, p) / nz;
	vec3 hit = vec3(p, depth);
	float edge = abs(length(hit) - radius);
	float band = 1.0 - smoothstep(width * 0.75, width, edge);
	float bevel = clamp(edge / width, 0.0, 1.0);
	float segments = cos(atan(hit.y, hit.x) * 24.0 + phase);
	float patina = cloud_noise(hit.xy * 56.0 + vec2(depth, phase) * 8.0);
	float shine = clamp(0.39 - hit.y * 0.27 + depth * 0.24 + bevel * 0.23
		+ segments * 0.055 + (patina - 0.5) * 0.17, 0.0, 1.0);
	vec3 tone = mix(vec3(0.17, 0.085, 0.044), vec3(0.74, 0.49, 0.24), shine);
	return vec4(tone * band, band);
}

vec3 spinning_armillary(vec3 color, vec2 p) {
	vec2 pivot = vec2(981.0, 293.0);
	vec2 q = (p - pivot) / vec2(185.0, 132.0);
	float plate = smoothstep(768.0, 791.0, p.x) * (1.0 - smoothstep(1166.0, 1192.0, p.x))
		* smoothstep(136.0, 152.0, p.y) * (1.0 - smoothstep(363.0, 371.0, p.y));
	if (plate <= 0.0) {
		return color;
	}
	vec3 backdrop = mix(color, texture(foundry_plate, p / ART).rgb, plate);
	float angle = TIME * 0.47;
	vec4 outer = bronze_ring(q, normalize(vec3(0.0, 0.94, 0.35)), 1.0, 0.061, angle);
	vec4 first = bronze_ring(q, spin_axis(normalize(vec3(0.94, 0.24, 0.15)), angle), 0.96, 0.060, angle);
	vec4 second = bronze_ring(q, spin_axis(normalize(vec3(0.13, -0.34, 0.94)), angle), 0.90, 0.050, -angle);
	vec4 small = bronze_ring(q, spin_axis(normalize(vec3(0.32, 0.81, 0.49)), -angle * 0.77), 0.68, 0.051, angle);
	vec3 result = backdrop;
	result = result * (1.0 - 0.77 * small.a) + 0.77 * small.rgb;
	result = result * (1.0 - 0.77 * second.a) + 0.77 * second.rgb;
	result = result * (1.0 - 0.87 * first.a) + 0.87 * first.rgb;
	result = result * (1.0 - 0.93 * outer.a) + 0.93 * outer.rgb;
	vec2 hub = rotate_point(q, sin(angle) * 0.46 + 0.22);
	float core_radius = max(abs(hub.x), abs(hub.y) * 0.80);
	float core = 1.0 - smoothstep(0.125, 0.143, core_radius);
	float lip = smoothstep(0.088, 0.118, core_radius);
	float rivet = 1.0 - smoothstep(0.025, 0.035, length(hub + vec2(0.032, 0.042)));
	vec3 core_metal = mix(vec3(0.38, 0.22, 0.12), vec3(0.68, 0.46, 0.24), lip * 0.66 + rivet * 0.33);
	result = mix(result, core_metal, core * 0.86);
	return mix(backdrop, result, 1.0 - smoothstep(357.0, 368.0, p.y));
}
