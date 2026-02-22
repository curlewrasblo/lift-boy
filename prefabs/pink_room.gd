extends Node3D
class_name PinkRoom

@export var follower : PathFollow3D
@export var move_speed : float = 0.5
@export var animator : AnimationPlayer

@export var walk_animation : StringName

@export var walk_speed : float = 1.0

func _ready() -> void:
	assert(animator != null, "Animator is not set")
	assert(walk_animation != "", "Walk animation is not set")
	assert(follower != null, "Follower is not set")

	animator.play(walk_animation)
	animator.speed_scale = walk_speed

func _process(delta: float) -> void:
	if !is_visible_in_tree():
		return

	follower.progress_ratio += delta * move_speed