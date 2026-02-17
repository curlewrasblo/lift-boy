shader_type spatial;
render_mode unshaded;

uniform sampler2D viewport_texture;

void fragment() {
	vec4 room = texture(viewport_texture, UV);
	ALBEDO = room.rgb;
}
