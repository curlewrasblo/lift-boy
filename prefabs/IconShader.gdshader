shader_type spatial;
render_mode unshaded, blend_mix, cull_back, depth_draw_never, depth_test_disabled;

uniform float icon_opacity = 0.0;

uniform sampler2D icon_texture : hint_default_white, repeat_disable;

uniform bool billboard = true;

void vertex() {
	if (billboard){
		MODELVIEW_MATRIX = VIEW_MATRIX * mat4(
			MAIN_CAM_INV_VIEW_MATRIX[0],
			MAIN_CAM_INV_VIEW_MATRIX[1],
			MAIN_CAM_INV_VIEW_MATRIX[2],
			MODEL_MATRIX[3]);
	MODELVIEW_NORMAL_MATRIX = mat3(MODELVIEW_MATRIX);
	}
}

void fragment() {
	vec4 icon_color = texture(icon_texture, UV);
	icon_color.a *= icon_opacity;
	ALBEDO = icon_color.rgb * COLOR.rgb;
	ALPHA = icon_color.a * COLOR.a;
}