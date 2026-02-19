extends Node3D
class_name Liftboy

@export var left_arm_IK_target : Marker3D
@export var left_arm_IK_modifier : IterateIK3D
@export var max_y_offset : float = 0.5

var press_tween : Tween

var original_left_arm_position : Vector3
var original_y_position : float

func _ready() -> void:
	original_left_arm_position = left_arm_IK_target.global_position
	original_y_position = position.y
	
func press_button(global_pos : Vector3) -> void:
	if press_tween != null:
		press_tween.kill()
		press_tween = null

	var y_distance = global_pos.y - original_y_position - max_y_offset
	var should_move_up = y_distance > 0.0

	left_arm_IK_modifier.active = true
	press_tween = create_tween().set_ease(Tween.EASE_OUT)
	press_tween.tween_property(left_arm_IK_target, "global_position", global_pos, 0.16).from(left_arm_IK_target.global_position)
	if should_move_up:
		press_tween.parallel().tween_property(self, "position:y", original_y_position + y_distance, 0.1).from(original_y_position)
	press_tween.tween_interval(0.21)
	press_tween.tween_property(left_arm_IK_target, "global_position", original_left_arm_position, 0.25)
	if should_move_up:
		press_tween.parallel().tween_property(self, "position:y", original_y_position, 0.1)
	press_tween.finished.connect(on_press_finished)


func on_press_finished() -> void:
	press_tween = null
	left_arm_IK_modifier.active = false
	position.y = original_y_position