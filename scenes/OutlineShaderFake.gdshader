shader_type spatial;
render_mode unshaded, cull_back;

uniform vec4 color : source_color;
uniform float intensity : hint_range(0.0, 10.0, 0.01) = 1.0;
uniform float outline_thickness : hint_range(0.0, 1.0, 0.001) = 0.05;

void vertex() {
	VERTEX += NORMAL * outline_thickness;
}

void fragment() {
	vec3 final_color = color.rgb * intensity;
	ALBEDO = final_color;
	EMISSION = final_color;
}
