shader_type spatial;
render_mode specular_schlick_ggx, diffuse_lambert;

uniform vec4 r_color : source_color;
uniform vec4 g_color : source_color;
uniform vec4 b_color : source_color;
uniform sampler2D rgb_uv_texture_separator: hint_default_black, repeat_disable;

uniform sampler2D normal_map_texture: hint_normal, repeat_enable;
uniform bool use_normal_map = false;

uniform float shade_steps : hint_range(2.0, 8.0) = 4.0;
uniform float diffuse_strength : hint_range(0.0, 1.5) = 0.65;
uniform float specular_strength : hint_range(0.0, 1.0) = 0.25;

void fragment() {
	vec3 rgb_texture = texture(rgb_uv_texture_separator, UV).rgb;
	vec3 r_amount = r_color.rgb * rgb_texture.r;
	vec3 g_amount = g_color.rgb * rgb_texture.g;
	vec3 b_amount = b_color.rgb * rgb_texture.b;
	vec3 total_rgb = r_amount + g_amount + b_amount;

	ALBEDO = total_rgb;
	if (use_normal_map) {
		NORMAL_MAP = texture(normal_map_texture, UV).rgb;
	}
}

void light() {
	float NdotL = clamp(dot(NORMAL, LIGHT), 0.0, 1.0);
	float stepped = floor(NdotL * shade_steps + 0.5) / shade_steps;
	DIFFUSE_LIGHT += diffuse_strength * stepped * ATTENUATION * LIGHT_COLOR / PI;

	vec3 H = normalize(VIEW + LIGHT);
	float NdotH = clamp(dot(NORMAL, H), 0.0, 1.0);
	float spec = floor(NdotH * shade_steps + 0.5) / shade_steps;
	SPECULAR_LIGHT += specular_strength * spec * ATTENUATION * LIGHT_COLOR * SPECULAR_AMOUNT;
}