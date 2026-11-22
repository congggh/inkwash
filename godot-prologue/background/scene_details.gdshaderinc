vec3 swinging_ink_bucket(sampler2D art, vec3 color, vec2 p, float center_x, float phase) {
	float x = p.x - center_x;
	if (abs(x) > 151.0 || p.y > 477.0) {
		return color;
	}
	float swing = sin(TIME * 1.16 + phase);
	float drop = sin(TIME * 1.16 + phase + 0.55);
	float reach = smoothstep(0.0, 375.0, p.y);
	float bowl = bounds_mask(p, vec2(center_x - 113.0, 333.0), vec2(center_x + 114.0, 465.0), 21.0);
	float chain_dist = min(abs(x - 102.0), abs(x + 105.0));
	float chain = (1.0 - smoothstep(8.0, 29.0, chain_dist))
		* (1.0 - smoothstep(365.0, 390.0, p.y));
	float weight = max(chain, bowl);
	vec2 from = p - vec2(swing * 16.0 * reach * weight, drop * 4.0 * reach * weight);
	vec3 motion = texture(art, from / ART).rgb;
	vec2 surface = (from - vec2(center_x, 358.0)) / vec2(84.0, 18.0);
	float radial = length(surface);
	float ink = 1.0 - smoothstep(0.75, 1.0, radial);
	float ripple = pow(0.5 + 0.5 * sin(radial * 32.0 - TIME * 4.9 + drop * 1.25), 4.0);
	float glint = cloud_noise(vec2(surface.x * 13.0 + TIME, surface.y * 4.0));
	return mix(color, motion, weight) + vec3(0.30, 0.23, 0.16) * ink * ripple * glint * 0.48;
}

vec3 maple_flag(sampler2D art, vec3 color, vec2 p) {
	float cloth = bounds_mask(p, vec2(173.0, 123.0), vec2(300.0, 259.0), 16.0);
	if (cloth <= 0.0) {
		return color;
	}
	float fabric = smoothstep(129.0, 236.0, p.y);
	float red_cloth = smoothstep(0.13, 0.39, color.r - color.b);
	float wave = maple_gust() * 9.0 + sin(TIME * 4.8 - p.y * 0.057) * 5.0;
	vec3 shifted = texture(art, (p + vec2(wave * fabric, 0.0)) / ART).rgb;
	return mix(color, shifted, fabric * cloth * red_cloth * 0.81);
}

vec3 stone_dragon_stream(vec3 color, vec2 p) {
	float line = water_column(p, 1362.0, 10.0, 268.0, 368.0, -0.025);
	if (line <= 0.0) {
		return color;
	}
	float current = cloud_noise(vec2(p.x * 0.34, (p.y - TIME * 172.0) / 21.0));
	float thread = line * smoothstep(0.51, 0.82, color.r);
	return color + vec3(0.44, 0.34, 0.21) * (current - 0.43) * thread;
}

vec3 winch_ink_splash(vec3 color, vec2 p) {
	if (abs(p.x - 973.0) > 33.0 || p.y < 486.0 || p.y > 528.0) {
		return color;
	}
	for (int drop = 0; drop < 3; drop++) {
		float age = winch_drop_age(drop);
		float progress = (age - 0.82) / 0.18;
		if (progress <= 0.0) {
			continue;
		}
		float spread = 3.0 + progress * (13.0 + float(drop) * 2.0);
		float bounce = sin(progress * 3.14159) * 18.0;
		vec2 particle = vec2(abs(p.x - 973.0) - spread, p.y - (513.0 - bounce));
		float stain = 1.0 - smoothstep(1.6, 3.8, length(particle));
		color = mix(color, vec3(0.054, 0.034, 0.021), stain * (1.0 - progress));
	}
	return color;
}

vec3 forge_embers(vec3 color, vec2 p) {
	float source_x = p.x < 950.0 ? 403.0 : 1555.0;
	vec2 distance = p - vec2(source_x, 433.0);
	if (abs(distance.x) > 103.0 || distance.y < -121.0 || distance.y > 22.0) {
		return color;
	}
	for (int spark = 0; spark < 8; spark++) {
		float seed = float(spark) + source_x * 0.01;
		float speed = hash_cell(vec2(seed, 6.7));
		float age = fract(TIME * (0.66 + 0.25 * speed) + float(spark) * 0.381);
		float side = 2.0 * hash_cell(vec2(seed, 9.1)) - 1.0;
		vec2 particle = vec2(side * (12.0 + age * 66.0), age * (-177.0 + age * 71.0) * (0.62 + speed * 0.37));
		vec2 q = distance - particle;
		float spark_light = 1.0 - smoothstep(1.2, 2.1 + speed * 2.4, length(q * vec2(1.0, 0.66)));
		float fade = smoothstep(0.0, 0.10, age) * (1.0 - smoothstep(0.56, 1.0, age));
		color = mix(color, vec3(1.0, 0.62 + speed * 0.24, 0.17), spark_light * fade);
	}
	return color;
}

vec3 forge_heat(sampler2D art, vec3 color, vec2 p) {
	vec2 source = p.x < 950.0 ? vec2(361.0, 281.0) : vec2(1584.0, 281.0);
	float reach = 1.0 - smoothstep(170.0, 650.0, abs(player_local - source.x));
	float plume = soft_region(p, source - vec2(0.0, 62.0), vec2(118.0, 116.0)) * reach;
	if (plume <= 0.0) {
		return color;
	}
	float air = cloud_noise(vec2(p.x / 31.0, (p.y + TIME * 85.0) / 19.0)) - 0.5;
	vec3 shifted = texture(art, (p + vec2(air * 15.0, air * 4.0)) / ART).rgb;
	return mix(color, shifted, plume * 0.78);
}

vec3 forge_reflected_light(vec3 color, vec2 p) {
	float glow = max(soft_region(p, vec2(404.0, 571.0), vec2(172.0, 53.0)),
		soft_region(p, vec2(1554.0, 571.0), vec2(170.0, 53.0)));
	float pulse = 0.48 + cloud_noise(vec2(TIME * 1.8, p.x / 147.0)) * 0.37;
	return color + color.r * glow * pulse * vec3(0.23, 0.084, 0.018);
}

vec3 stele_surface(vec3 color, vec2 p) {
	float reach = 1.0 - smoothstep(95.0, 410.0, abs(player_local - p.x));
	float gold = smoothstep(0.14, 0.31, color.r - color.b)
		* smoothstep(0.36, 0.61, color.r) * (1.0 - smoothstep(0.51, 0.68, color.b));
	float beam = 1.0 - smoothstep(28.0, 108.0, abs(p.x - player_local + (p.y - 270.0) * 0.54));
	color += gold * beam * reach * vec3(0.28, 0.19, 0.058);
	float drift = p.x - TIME * 31.0;
	float lobe = cloud_noise(vec2(drift / 168.0, 4.3));
	float y = (p.y - 437.0 + lobe * 31.0) / 33.0;
	float fold = cloud_noise(vec2(drift / 113.0, (p.y + TIME * 6.0) / 29.0));
	float mist = exp(-y * y) * smoothstep(0.29, 0.75, fold) * 0.40;
	return mix(color, vec3(0.83, 0.73, 0.65), mist);
}

vec3 storm_light(vec3 color, vec2 p) {
	if (storm_age < 0.0 || storm_age > 0.68) {
		return color;
	}
	float flash = exp(-storm_age * 14.0) * smoothstep(0.0, 0.032, storm_age);
	float echo = max(0.0, storm_age - 0.23);
	flash += 0.48 * smoothstep(0.0, 0.045, echo) * exp(-echo * 13.0);
	float ridge = soft_region(p, vec2(1510.0, 178.0), vec2(780.0, 395.0));
	float delay = max(0.0, storm_age - 0.072);
	float bridge_flash = smoothstep(0.0, 0.049, delay) * exp(-delay * 7.0);
	float bridge = soft_region(p, vec2(1250.0, 555.0), vec2(925.0, 68.0));
	return color + vec3(0.29, 0.24, 0.27) * (flash * ridge * 0.66 + bridge_flash * bridge * 0.40);
}
