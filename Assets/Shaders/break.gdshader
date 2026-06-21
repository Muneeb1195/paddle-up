shader_type canvas_item;

uniform float progress : hint_range(0, 1) = 0;
uniform float fragment_size : hint_range(0, 50) = 5;
uniform float strength : hint_range(0, 3) = 3.0;

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

vec2 hash2(vec2 p) {
	return vec2(hash(p), hash(p + vec2(31.0, 17.0)));
}

void fragment() {
	vec2 uv = UV;
	vec2 center = vec2(0.5, 0.5);
	float dist_to_center = distance(uv, center) * 2.0;

	vec2 frag_id = floor(uv / (fragment_size * TEXTURE_PIXEL_SIZE.xy));
	vec2 frag_seed = hash2(frag_id);

	float local_progress = clamp(progress * (0.6 + frag_seed.x * 0.6), 0.0, 1.0);

	vec2 dir = normalize(center - uv + vec2(0.001));
	float collapse = strength * pow(local_progress, 0.5) * (0.8 + frag_seed.y * 0.4);
	vec2 offset = dir * collapse * dist_to_center;

	float angle = (frag_seed.x - 0.5) * local_progress * 3.0;
	mat2 rot = mat2(
		vec2(cos(angle), -sin(angle)),
		vec2(sin(angle), cos(angle))
	);
	offset = rot * offset;

	float scale = 1.0 - local_progress * 0.6;
	vec2 sample_uv = center + (uv - center) * scale - offset;
	sample_uv = clamp(sample_uv, vec2(0.0), vec2(1.0));
	vec4 tex_color = texture(TEXTURE, sample_uv);

	tex_color.rgb *= 1.0 - local_progress * 0.5;

	float flash = exp(-dist_to_center * 3.0) * (1.0 - local_progress);
	tex_color.rgb += vec3(flash * 0.6);

	COLOR = tex_color * COLOR;
	COLOR.a *= 1.0 - local_progress * 0.8;
}
