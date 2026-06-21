shader_type canvas_item;

uniform float progress : hint_range(0.0, 1.0) = 0.0;
uniform float twist : hint_range(0.0, 10.0) = 2.0;

void fragment() {
	vec2 uv = UV - 0.5;
	float dist = length(uv);
	float angle = atan(uv.y, uv.x);
	angle += progress * twist * (1.0 - dist);
	vec2 warped_uv = vec2(cos(angle), sin(angle)) * dist * (1.0 - progress);
	warped_uv += 0.5;
	vec4 tex_color = texture(TEXTURE, warped_uv);
	float alpha_clip = step(progress, 1.0 - dist);
	tex_color.a *= alpha_clip;
	tex_color.rgb = mix(tex_color.rgb, COLOR.rgb, progress);
	COLOR = tex_color;
}
