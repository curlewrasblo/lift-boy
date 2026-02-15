shader_type spatial;
uniform float moving : hint_range(-1, 1);

uniform float move_max_speed = 1.0;

uniform vec4 normal_color : source_color;
uniform vec4 speedy_color : source_color;

uniform sampler2D moving_texture : hint_default_white, repeat_enable;
uniform vec2 tex_tiling = vec2(1, 1);

void fragment() {
	vec2 uv = SCREEN_UV;
	uv = uv * tex_tiling;
	
	float y_movement = TIME * -moving * move_max_speed;
	
	uv.y += y_movement;
	
	vec4 noise = texture(moving_texture, uv);
	
	float speedy_factor = noise.r * abs(moving);
	
	vec3 color = mix(normal_color, speedy_color, speedy_factor).rgb;
	
	ALBEDO = color;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
