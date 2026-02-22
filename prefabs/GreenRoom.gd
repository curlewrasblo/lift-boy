extends Node3D
class_name GreenRoom


@export var walking_guest : Node3D

@export var walking_guest_path_follow : PathFollow3D

@export var walking_guest_animator : AnimationPlayer

@export var movement_speed : float = 1.0

var path_walker : float = 0.0

func _ready() -> void:
	assert(walking_guest != null, "Walking guest is not set")
	assert(walking_guest_animator != null, "Walking guest animator is not set")
	walking_guest_animator.speed_scale = 2.2
	walking_guest_animator.play("Walk")

func _process(delta: float) -> void:
	if !is_visible_in_tree():
		return

	walking_guest_path_follow.progress_ratio += delta * movement_speed