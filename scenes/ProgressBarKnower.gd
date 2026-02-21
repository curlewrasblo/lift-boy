extends ProgressBar
class_name ProgressBarKnower


func get_ui_position_of_progress() -> Vector2:
	var pos = global_position
	pos.x = pos.x + (value / max_value) * size.x
	return pos