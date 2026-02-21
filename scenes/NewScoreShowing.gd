extends RichTextLabel
class_name NewScoreShowing

signal on_finished(score_shower: NewScoreShowing)

@export var progress_bar_knower: ProgressBarKnower

var tween: Tween

var pre_string := "[b]"

func _ready() -> void:
	visible = false

func _on_vibe_points_changed(point_change: int) -> void:
	give_vibe_points(point_change)

func is_available() -> bool:
	return !visible

func give_vibe_points(points: int) -> void:
	var score_points = points * 10
	if score_points > 0:
		text = pre_string + "+" + str(score_points)
	else:
		text = pre_string + str(score_points)

	global_position = progress_bar_knower.get_ui_position_of_progress() + Vector2(size.x / 1.5, 0.0)

	modulate.a = 1.0
	visible = true

	tween = create_tween().set_trans(Tween.TRANS_BACK)
	tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.15).from(Vector2.ONE)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.25)
	tween.tween_interval(0.8)
	tween.tween_property(self, "modulate:a", 0.0, 0.6).from(1.0)
	tween.tween_callback(_on_tween_completed)

func _on_tween_completed() -> void:
	on_finished.emit(self)
	visible = false