extends Node3D
class_name DarkRoom

@export var follower : PathFollow3D
@export var move_speed : float = 0.5

func _process(delta: float) -> void:
	if !is_visible_in_tree():
		return

	follower.progress_ratio += delta * move_speed