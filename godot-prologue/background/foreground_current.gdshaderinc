float ink_bank_mask(vec2 p) {
	float middle = soft_region(p, vec2(1000.0, 801.0), vec2(826.0, 266.0));
	float near_edge = soft_region(p, vec2(1050.0, 837.0), vec2(1120.0, 127.0));
	return max(middle, near_edge) * smoothstep(555.0, 674.0, p.y);
}

vec3 foreground_current(sampler2D art, vec3 color, vec2 p) {
	float basin = ink_bank_mask(p);
	if (basin < 0.005) {
		return color;
	}
	float speed = abs(foreground_motion);
	float ahead = player_local + foreground_motion * 138.0;
	float distance = abs(p.x - ahead);
	float wake = (1.0 - smoothstep(26.0, 265.0, distance)) * speed;
	float band = cloud_noise(vec2((p.x - TIME * 68.0) / 166.0, p.y / 55.0));
	float tide = sin(p.x / 63.0 - TIME * 2.5 + p.y * 0.026);
	float crest_y = 665.0 + band * 43.0 + sin(p.x * 0.018 - TIME * 3.2) * 12.0
		- wake * 54.0;
	float near_crest = 1.0 - smoothstep(9.0, 81.0, abs(p.y - crest_y));

	// Advect the painted foam inside the basin and lift the crest ahead of the character.
	vec2 shift = vec2(tide * (13.0 + wake * 14.0) + foreground_motion * wake * 9.0,
		(band - 0.5) * 32.0 + tide * 10.0 + wake * near_crest * 25.0);
	vec2 sample_at = p + shift * basin;
	sample_at.y = clamp(sample_at.y, 557.0, ART.y - 1.0);
	vec3 water = texture(art, sample_at / ART).rgb;
	color = mix(color, water, basin * 0.78);

	float spray = cloud_noise(vec2((p.x - TIME * 105.0) / 34.0, (p.y + TIME * 20.0) / 18.0));
	float white_edge = (1.0 - smoothstep(2.0, 12.0, abs(p.y - crest_y)))
		* smoothstep(0.40, 0.78, spray) * wake * basin;
	return mix(color, vec3(0.82, 0.75, 0.68), white_edge * 0.56);
}

vec3 falling_gravel(vec3 color, vec2 p, vec2 ledge, float age, float outward) {
	if (age < 0.0 || age > 1.1 || abs(p.x - ledge.x) > 123.0 || p.y < ledge.y - 12.0) {
		return color;
	}
	for (int index = 0; index < 5; index++) {
		float number = float(index);
		float t = age - number * 0.08;
		if (t < 0.0 || t > 0.77) {
			continue;
		}
		float seed = hash_cell(vec2(ledge.x, number + 3.5));
		vec2 stone = ledge + vec2(outward * (number * 9.0 + t * (40.0 + seed * 67.0)),
			-4.0 + seed * 16.0 + t * t * (181.0 + seed * 75.0));
		vec2 q = rotate_point(p - stone, t * 3.0 + number);
		float size = 3.0 + seed * 3.6;
		float body = 1.0 - smoothstep(0.66, 1.0, abs(q.x / size) + abs(q.y / (size * 0.69)));
		float face = smoothstep(-size * 0.5, size * 0.55, -q.y + q.x * 0.4);
		vec3 tint = mix(vec3(0.14, 0.10, 0.082), vec3(0.59, 0.45, 0.34), face);
		color = mix(color, tint, body * (1.0 - smoothstep(0.58, 0.77, t)));
	}
	return color;
}
