shader_type canvas_item;

uniform vec4 color : source_color;

uniform float fade_progress : hint_range(0, 1) = 0.0;

void fragment() {
	COLOR = vec4(color.rgb, color.a * (1.0 - fade_progress));
}
