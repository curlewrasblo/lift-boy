extends Node3D
class_name Room

signal on_room_loaded()
signal on_room_unloaded()

func _ready() -> void:
	unload_room()

func load_room() -> void:
	visible = true
	on_room_loaded.emit()
func unload_room() -> void:
	visible = false
	on_room_unloaded.emit()