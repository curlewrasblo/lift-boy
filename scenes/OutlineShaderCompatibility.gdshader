shader_type spatial;
render_mode blend_mix, cull_front, unshaded;

uniform vec4 outline_color: source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float outline_width: hint_range(0.0, 0.2, 0.001) = 0.02;

void vertex() {
	VERTEX *= 1.0 + outline_width;
}

void fragment() {
	ALBEDO = outline_color.rgb;
}
