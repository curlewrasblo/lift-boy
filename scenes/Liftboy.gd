extends Node3D
class_name Liftboy

@export var left_arm_IK_target: Marker3D
@export var left_arm_IK_modifier: SkeletonModifier3D
@export var head_IK_modifier: LookAtModifier3D
@export var max_y_offset: float = 0.5
@export var middle_pos: Vector3 = Vector3.ZERO
@export var victory_animator: AnimationPlayer
@export var victory_anim: StringName

var press_tween: Tween

var original_left_arm_position: Vector3
var original_y_position: float

var looking_timer: float = 0.0

func _ready() -> void:
	original_left_arm_position = left_arm_IK_target.global_position
	original_y_position = position.y
	head_IK_modifier.active = true
	head_IK_modifier.target_node = NodePath("")

func _process(delta: float) -> void:
	if !head_IK_modifier.target_node.is_empty():
		looking_timer -= delta
		if looking_timer <= 0.0:
			head_IK_modifier.target_node = NodePath("")
			looking_timer = 0.0


func press_button(global_pos: Vector3) -> void:
	if press_tween != null:
		press_tween.kill()
		press_tween = null

	var y_distance = global_pos.y - original_y_position - max_y_offset
	var should_move_up = y_distance > 0.0

	left_arm_IK_modifier.active = true
	press_tween = create_tween().set_ease(Tween.EASE_OUT)
	press_tween.tween_property(left_arm_IK_target, "position", middle_pos, 0.08).from(left_arm_IK_target.position)
	press_tween.tween_property(left_arm_IK_target, "global_position", global_pos, 0.08)
	if should_move_up:
		press_tween.parallel().tween_property(self, "position:y", original_y_position + y_distance * 0.75, 0.082).from(original_y_position)
	press_tween.tween_interval(0.21)
	press_tween.tween_property(left_arm_IK_target, "global_position", original_left_arm_position, 0.25)
	if should_move_up:
		press_tween.parallel().tween_property(self, "position:y", original_y_position, 0.1)
	press_tween.finished.connect(on_press_finished)


func on_press_finished() -> void:
	press_tween = null
	left_arm_IK_modifier.active = false
	position.y = original_y_position

func look_at_guest(guest: Node3D, never_stop: bool = false) -> void:
	head_IK_modifier.target_node = head_IK_modifier.get_path_to(guest)
	looking_timer = randf_range(1.6, 3.0)
	if never_stop:
		looking_timer = 1000000.0

func play_and_await_victory_animation() -> void:
	victory_animator.play(victory_anim)
	await victory_animator.animation_finished
