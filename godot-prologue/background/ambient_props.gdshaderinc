float bounds_mask(vec2 p, vec2 start, vec2 end, float feather) {
	vec2 enter = smoothstep(start - feather, start, p);
	vec2 leave = 1.0 - smoothstep(end, end + feather, p);
	return enter.x * enter.y * leave.x * leave.y;
}

vec4 phoenix_sprite(vec2 p, vec2 center, float size, float orbit, float beat) {
	float turning = -sin(orbit);
	float width = mix(0.44, 1.0, smoothstep(0.0, 0.42, abs(turning)));
	vec2 q = rotate_point(p - center, sin(orbit) * 0.12);
	q.x *= (turning < 0.0 ? -1.0 : 1.0) / width;
	float flutter = 1.0 + 0.15 * sin(beat) * smoothstep(30.0, 155.0, abs(q.x));
	vec2 uv = (q / vec2(485.0, 162.0 * flutter)) / size + 0.5;
	if (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0) {
		return vec4(0.0);
	}
	return texture(phoenix_art, uv);
}

vec3 flying_phoenix(vec3 color, vec2 p) {
	float old_birds = max(bounds_mask(p, vec2(718.0, 24.0), vec2(1213.0, 183.0), 17.0),
		bounds_mask(p, vec2(1482.0, 104.0), vec2(1658.0, 180.0), 13.0));
	vec2 aligned_plate = vec2(p.x, p.y * 0.83);
	vec3 sky = mix(color, texture(phoenix_plate, aligned_plate / ART).rgb, old_birds);
	float orbit = TIME * 0.38;
	vec2 close_path = vec2(963.0 + cos(orbit) * 294.0, 145.0 + sin(orbit) * 54.0);
	vec4 phoenix = phoenix_sprite(p, close_path, 0.83 + 0.19 * sin(orbit), orbit, TIME * 4.5);
	float far_orbit = TIME * 0.49 + 1.20;
	vec2 far_path = vec2(1490.0 + cos(far_orbit) * 203.0, 124.0 + sin(far_orbit) * 37.0);
	vec4 far_bird = phoenix_sprite(p, far_path, 0.39, far_orbit, TIME * 5.5 + 0.8);
	sky = mix(sky, far_bird.rgb, far_bird.a * 0.66);
	sky = mix(sky, phoenix.rgb, phoenix.a * 0.98);
	// Keep the painted chains in front of both flight paths.
	float chain = min(min(abs(p.x - 700.0), abs(p.x - 905.0)),
		min(abs(p.x - 1265.0), abs(p.x - 1473.0)));
	float occlusion = (1.0 - smoothstep(5.0, 11.0, chain))
		* (1.0 - smoothstep(0.22, 0.39, color.r));
	return mix(sky, color, occlusion);
}

float maple_gust() {
	return sin(TIME * 1.45) * 0.70 + sin(TIME * 2.60 + 0.6) * 0.30;
}

vec3 falling_maple_leaves(vec3 color, vec2 p) {
	if (p.x > 615.0 || p.y > 494.0) {
		return color;
	}
	for (int leaf = 0; leaf < 17; leaf++) {
		float seed = float(leaf);
		float random = hash_cell(vec2(seed, 2.5));
		float age = fract(TIME * (0.20 + random * 0.12) + seed * 0.618);
		vec2 crown = vec2(26.0 + hash_cell(vec2(seed, 8.0)) * 334.0, 19.0 + 79.0 * random);
		vec2 sway = vec2(age * (125.0 + random * 92.0) + sin(age * 13.0 + seed) * 27.0,
			age * (333.0 + 63.0 * random));
		sway.x += maple_gust() * 23.0 * age;
		vec2 q = p - crown - sway;
		float size = 5.0 + random * 5.0;
		if (dot(q, q) > size * size * 2.0) {
			continue;
		}
		q = rotate_point(q, age * 8.7 + seed);
		q.x /= 0.54 + 0.46 * abs(cos(age * 9.0 + seed));
		float lobe = 0.71 + 0.24 * cos(atan(q.y, q.x) * 5.0 + 0.5);
		float shape = 1.0 - smoothstep(lobe - 0.16, lobe, length(q) / size);
		float visible = smoothstep(0.025, 0.095, age) * (1.0 - smoothstep(0.81, 1.0, age));
		vec3 red = mix(vec3(0.64, 0.055, 0.035), vec3(1.0, 0.25, 0.10), random);
		color = mix(color, red, shape * visible * 0.93);
	}
	return color;
}

float winch_drop_age(int drop) {
	return fract(TIME * 0.63 + float(drop) * 0.33);
}

vec3 moving_winch_lines(sampler2D art, vec3 color, vec2 p) {
	if (p.y < 121.0 || p.y > 515.0 || p.x < 720.0 || p.x > 1200.0) {
		return color;
	}
	float height = p.y - 130.0;
	float rope = min(min(abs(p.x - (754.0 - height * 0.055)), abs(p.x - (805.0 - height * 0.045))),
		min(abs(p.x - (1131.0 + height * 0.032)), abs(p.x - (1163.0 + height * 0.052))));
	float flex = smoothstep(131.0, 205.0, p.y) * (1.0 - smoothstep(487.0, 518.0, p.y));
	float shift = sin(TIME * 2.4 + p.y * 0.013) * 7.0 * flex;
	float scroll = sin(TIME * 3.7) * 13.0 * flex;
	vec3 moving = texture(art, (p + vec2(shift, scroll)) / ART).rgb;
	color = mix(color, moving, (1.0 - smoothstep(9.0, 31.0, rope)) * flex);

	// Replace the drops painted in mid-air; keep the ink still attached to the hook.
	float ink_x = 973.0;
	if (abs(p.x - ink_x) > 29.0 || p.y < 343.0) {
		return color;
	}
	float painted_ink = (1.0 - smoothstep(16.0, 26.0, abs(p.x - ink_x)))
		* smoothstep(343.0, 356.0, p.y) * (1.0 - smoothstep(505.0, 517.0, p.y));
	vec2 clean = vec2(p.x + 39.0, p.y);
	color = mix(color, texture(art, clean / ART).rgb, painted_ink);
	for (int drop = 0; drop < 3; drop++) {
		float age = winch_drop_age(drop);
		float fall = min(age / 0.82, 1.0);
		vec2 center = vec2(ink_x + sin(age * 7.0 + float(drop)) * 3.0, 339.0 + 176.0 * fall * fall);
		float stretch = 1.0 + 1.15 * age;
		vec2 drop_shape = (p - center) / vec2(4.1 + float(drop), (7.0 + float(drop) * 2.0) * stretch);
		float silhouette = 1.0 - smoothstep(0.74, 1.0, length(drop_shape));
		float opacity = silhouette * smoothstep(0.02, 0.09, age) * (1.0 - smoothstep(0.79, 0.85, age));
		float glint = 1.0 - smoothstep(0.18, 0.52, length(drop_shape + vec2(0.31, 0.27)));
		color = mix(color, mix(vec3(0.033, 0.024, 0.020), vec3(0.44, 0.31, 0.22), glint), opacity);
	}
	return color;
}

const float SWORD_X[6] = float[6](379.0, 589.0, 769.0, 1150.0, 1311.0, 1517.0);
const float SWORD_LENGTH[6] = float[6](164.0, 171.0, 130.0, 135.0, 170.0, 166.0);

vec3 falling_swords(sampler2D art, vec3 color, vec2 p) {
	for (int index = 0; index < 6; index++) {
		float x = SWORD_X[index];
		float blade_length = SWORD_LENGTH[index];
		if (abs(p.x - x) > 44.0) {
			continue;
		}
		float age = mod(TIME + float(index) * 0.86, 6.1);
		float fall = clamp((age - 2.75) / 0.96, 0.0, 1.0);
		float return_from_above = -blade_length * (1.0 - smoothstep(5.30, 6.10, age));
		float offset = age >= 5.30 ? return_from_above : fall * fall * 550.0;
		if (abs(offset) < 0.2) {
			return color;
		}
		float old_blade = bounds_mask(p, vec2(x - 30.0, 0.0), vec2(x + 30.0, blade_length + 6.0), 13.0);
		color = mix(color, texture(sword_plate, p / ART).rgb, old_blade);
		float blade_y = p.y - offset;
		if (blade_y < 0.0 || blade_y > blade_length || p.y > 504.0) {
			return color;
		}
		float half_width = 24.0 * (1.0 - smoothstep(blade_length * 0.64, blade_length + 3.0, blade_y));
		float edge = 1.0 - smoothstep(half_width - 3.0, half_width, abs(p.x - x));
		float tip = (1.0 - smoothstep(488.0, 504.0, p.y)) * smoothstep(0.0, 5.0, blade_y);
		vec3 blade = texture(art, vec2(p.x, blade_y) / ART).rgb;
		return mix(color, blade, edge * tip);
	}
	return color;
}

vec3 running_lava(sampler2D art, vec3 color, vec2 p, bool under_bridge) {
	float channel = 0.0;
	if (under_bridge) {
		channel = smoothstep(615.0, 672.0, p.y);
	} else {
		channel = max(water_column(p, 391.0, 35.0, 303.0, 444.0, 0.12),
			water_column(p, 1565.0, 34.0, 303.0, 440.0, -0.09));
	}
	float hot = smoothstep(0.17, 0.47, color.r - color.b)
		* smoothstep(0.42, 0.88, color.r) * channel;
	if (hot < 0.005) {
		return color;
	}
	float flow = fract(TIME * 1.8);
	float other = fract(flow + 0.5);
	vec3 first = texture(art, (p + vec2(0.0, (0.5 - flow) * 50.0)) / ART).rgb;
	vec3 second = texture(art, (p + vec2(0.0, (0.5 - other) * 50.0)) / ART).rgb;
	float roughness = cloud_noise(vec2(p.x / 17.0, (p.y - TIME * 155.0) / 38.0));
	return mix(color, mix(first, second, abs(flow * 2.0 - 1.0)), hot * 0.61)
		+ vec3(0.25, 0.10, 0.018) * (roughness - 0.43) * hot;
}
