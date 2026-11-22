float water_column(vec2 p, float x, float width, float top, float bottom, float lean) {
	float center = x + (p.y - top) * lean;
	float side = 1.0 - smoothstep(width * 0.42, width, abs(p.x - center));
	return side * smoothstep(top - 30.0, top + 35.0, p.y)
		* (1.0 - smoothstep(bottom - 35.0, bottom + 25.0, p.y));
}

vec3 animate_water(sampler2D art, vec3 color, vec2 point, vec2 local, int section) {
	float mask = 0.0;
	if (section == 1) {
		mask = max(water_column(local, 1236.0, 47.0, 218.0, 336.0, 0.08),
			max(water_column(local, 1265.0, 55.0, 367.0, 451.0, -0.12),
				water_column(local, 1240.0, 52.0, 429.0, 518.0, -0.26)));
	} else if (section == 2) {
		mask = water_column(local, 1522.0, 47.0, 244.0, 384.0, 0.10);
	} else if (section == 7 && !inner_track) {
		mask = max(water_column(local, 197.0, 63.0, 239.0, 345.0, 0.18),
			water_column(local, 514.0, 70.0, 334.0, 409.0, 0.14));
	} else if (section == 11) {
		mask = max(water_column(local, 950.0, 215.0, -70.0, 525.0, 0.03),
			max(water_column(local, 1275.0, 83.0, 132.0, 520.0, -0.17),
			max(water_column(local, 535.0, 113.0, 242.0, 518.0, 0.26),
				water_column(local, 1590.0, 86.0, 252.0, 518.0, -0.13))));
	} else if (section == 12) {
		mask = max(water_column(local, 286.0, 109.0, -55.0, 510.0, 0.08),
			max(water_column(local, 1320.0, 104.0, 149.0, 279.0, 0.12),
				water_column(local, 1465.0, 116.0, 285.0, 515.0, 0.17)));
	} else if (section == 13) {
		mask = max(water_column(local, 428.0, 58.0, 153.0, 467.0, -0.18),
			max(water_column(local, 750.0, 56.0, 235.0, 367.0, 0.28),
				water_column(local, 782.0, 64.0, 342.0, 480.0, 0.30)));
	}
	if (mask <= 0.0) {
		return color;
	}
	float water = mask * smoothstep(0.39, 0.77, dot(color, vec3(0.21, 0.59, 0.20)))
		* (1.0 - smoothstep(0.14, 0.32, color.r - color.b));
	if (water > 0.01) {
		float phase = fract(TIME * 2.2);
		float second = fract(phase + 0.5);
		vec3 flow_a = read_art(art, point + vec2(0.0, (0.5 - phase) * 38.0));
		vec3 flow_b = read_art(art, point + vec2(0.0, (0.5 - second) * 38.0));
		color = mix(color, mix(flow_a, flow_b, abs(phase * 2.0 - 1.0)), water * 0.58);
	}
	float fast_flow = cloud_noise(vec2(local.x / 16.0, (local.y - TIME * 240.0) / 78.0));
	float slow_flow = cloud_noise(vec2(local.x / 43.0, (local.y - TIME * 131.0) / 113.0));
	float streak = (mix(fast_flow, slow_flow, 0.35) - 0.5) * 0.67 * water;
	return color + streak * vec3(0.80, 0.88, 0.90);
}

vec3 animate_sky(vec3 color, vec2 local, vec2 world, int section) {
	float height = 157.0;
	if (section == 0) {
		height *= smoothstep(940.0, 1530.0, local.x);
	} else if (section == 2 || section == 7) {
		height *= smoothstep(720.0, 1550.0, local.x);
	} else if (section >= 3 && section <= 6) {
		height *= 0.40;
	}
	float sky = 1.0 - smoothstep(height * 0.57, height + 60.0, local.y);
	float warmth = color.r - color.b;
	float painted_sky = smoothstep(0.11, 0.25, warmth) * smoothstep(0.20, 0.49, color.r);
	float coverage = sky * painted_sky;
	if (coverage <= 0.005) {
		return color;
	}
	vec2 wind = world - vec2(TIME * 60.0, TIME * 2.0);
	float body = cloud_noise(wind / vec2(275.0, 54.0));
	float detail = cloud_noise(wind / vec2(93.0, 19.0));
	float grain = cloud_noise(wind / vec2(26.0, 8.0));
	float field = body * 0.69 + detail * 0.23 + grain * 0.08;
	float cloud = smoothstep(0.49, 0.63, field);
	float rim = smoothstep(0.43, 0.55, field) * (1.0 - cloud);
	vec3 tint = inner_track ? vec3(0.64, 0.53, 0.42)
		: mix(vec3(0.14, 0.067, 0.073), vec3(0.26, 0.095, 0.085), detail);
	color = mix(color, tint, coverage * cloud * (inner_track ? 0.15 : 0.74));
	return mix(color, vec3(0.57, 0.19, 0.13), coverage * rim * (inner_track ? 0.0 : 0.21));
}

vec3 reveal_sunlight(vec3 color, vec2 p, float intensity, bool stone_gate) {
	vec2 center = stone_gate ? vec2(1010.0, 285.0) : vec2(1556.0, 306.0);
	vec2 radius = stone_gate ? vec2(465.0, 386.0) : vec2(322.0, 329.0);
	float opening = soft_region(p, center, radius);
	float warmth = smoothstep(0.09, 0.27, color.r - color.b) * smoothstep(0.36, 0.80, color.r);
	color *= 1.0 - (1.0 - intensity) * opening * warmth * 0.62;
	float center_x = stone_gate ? 1290.0 - (p.y - 105.0) * 1.44 : 1650.0 - (p.y - 130.0) * 0.91;
	float ray = 1.0 - smoothstep(32.0, 138.0, abs(p.x - center_x));
	float second = 1.0 - smoothstep(13.0, 79.0, abs(p.x - center_x - 178.0));
	float reach = smoothstep(55.0, 143.0, p.y) * (1.0 - smoothstep(434.0, 530.0, p.y));
	float dust = cloud_noise((p - vec2(TIME * 7.0, -TIME * 9.0)) / vec2(81.0, 63.0));
	float glow = max(ray, second * 0.52) * opening * reach * (0.24 + dust * 0.12) * intensity;
	return mix(color, vec3(1.0, 0.79, 0.48), glow);
}

vec3 drifting_mist(vec3 color, vec2 p, float world_x, float bank, int section) {
	bool spray = section >= 11;
	bool forge = section == 3 || section == 6;
	float drift = world_x - TIME * (spray ? 35.0 : 19.0);
	float altitude = cloud_noise(vec2(drift / 360.0, 2.7)) * 70.0;
	float above = (p.y - bank + 37.0 + altitude) / 53.0;
	float below = (p.y - 753.0 + altitude * 0.5) / 64.0;
	float bank_band = exp(-above * above);
	float gorge_band = exp(-below * below);
	float vertical_motion = forge ? TIME * 21.0 : TIME * 6.0;
	vec2 wind = vec2(drift, p.y + vertical_motion);
	float shape = cloud_noise(wind / vec2(236.0, 47.0)) * 0.73
		+ cloud_noise(wind / vec2(102.0, 25.0)) * 0.27;
	float density = smoothstep(0.35, 0.79, shape) * (bank_band * (spray ? 0.29 : 0.18) + gorge_band * 0.15);
	vec3 tint = spray ? vec3(0.78, 0.91, 0.89) : vec3(0.79, 0.67, 0.56);
	if (forge && !inner_track) {
		tint = vec3(0.85, 0.53, 0.36);
	}
	return mix(color, tint, density * (inner_track ? 0.46 : 1.0));
}
