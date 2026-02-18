shader_type spatial;
render_mode diffuse_lambert, specular_schlick_ggx;

uniform vec4 albedo : source_color;
uniform float opacity = 1.0;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	ALBEDO = albedo.rgb;
	ALPHA = opacity;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
