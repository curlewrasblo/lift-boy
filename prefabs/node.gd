extends Node

@export var animator: AnimationPlayer

func _ready() -> void:
	assert(animator != null, "Animator is not set")
	animator.play("Walk")