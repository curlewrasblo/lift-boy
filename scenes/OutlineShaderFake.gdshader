shader_type spatial;
render_mode unshaded;

uniform vec4 color : source_color;
uniform float intensity : hint_range(0.0, 10.0, 0.01) = 1.0;

void fragment() {
	vec3 final_color = color.rgb * intensity;
	ALBEDO = final_color;
	EMISSION = final_color;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
