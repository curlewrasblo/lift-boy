shader_type spatial;
render_mode unshaded, cull_back;

uniform vec4 albedo : source_color;
uniform float intensity;


void fragment() {
	ALBEDO = albedo.rgb * intensity;
	//EMISSION = albedo.rgb * intensity;
}