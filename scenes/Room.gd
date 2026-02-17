extends Node3D
class_name Room

func _ready() -> void:
	unload_room()

func load_room() -> void:
	visible = true

func unload_room() -> void:
	visible = false