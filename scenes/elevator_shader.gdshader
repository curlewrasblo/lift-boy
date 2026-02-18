shader_type spatial;
render_mode unshaded;

uniform float uv_offset = 0.0;
uniform float moving_factor = 0.0;

uniform vec4 still_color_1 : source_color;
uniform vec4 still_color_2 : source_color;
uniform vec4 moving_slow_color : source_color;
uniform vec4 moving_fast_color : source_color;

uniform sampler2D still_texture : hint_default_black, repeat_disable;
uniform sampler2D moving_texture : hint_default_white, repeat_enable;
uniform vec2 tex_tiling = vec2(1, 1);

void fragment() {
	vec2 uv = SCREEN_UV;
	uv = uv * tex_tiling;
	
	uv.y += -uv_offset;
	
	float noise = texture(moving_texture, uv).r;
	
	vec4 moving_color = mix(moving_slow_color, moving_fast_color, noise);
	
	float still_tex = texture(still_texture, SCREEN_UV).r;
	vec4 still_color = mix(still_color_1, still_color_2, still_tex);
	
	vec4 color = mix(still_color, moving_color, moving_factor);
	
	ALBEDO = color.rgb;
}
