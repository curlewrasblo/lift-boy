extends CanvasItem

@export var fade_duration: float = 1.3

var tween: Tween = null

func instant_fade_in() -> void:
	material.set_shader_parameter("fade_progress", 0.0)

var is_fading: bool = false
func fade_out() -> void:
	if is_fading:
		return
	is_fading = true
	if tween:
		tween.kill()
		tween = null
	
	tween = create_tween().set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(material, "shader_parameter/fade_progress", 1.0, fade_duration)

	await tween.finished
	is_fading = false

func fade_in() -> void:
	if is_fading:
		return
	is_fading = true
	if tween:
		tween.kill()
		tween = null
	
	tween = create_tween().set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(material, "shader_parameter/fade_progress", 0.0, fade_duration)

	await tween.finished
	is_fading = false