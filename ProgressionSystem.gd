extends Node

signal on_level_increased()

var current_level: int = 1

func increase_level() -> void:
	current_level = 2
	on_level_increased.emit()