extends Marker3D
class_name LiftMark

signal on_guest_arrived(sender: LiftMark, guest: Guest)
signal on_mark_left(sender: LiftMark, guest: Guest)

var move_tween: Tween
var guest: Guest = null

func walk_to_mark(duration: float, walking_guest: Guest) -> void:
	assert(is_available(), "Mark is not available")
	guest = walking_guest

	_handle_guest_movement(duration)

func is_available() -> bool:
	return guest == null

func _handle_guest_movement(duration: float) -> void:
	if move_tween != null:
		move_tween.kill()
		move_tween = null

	move_tween = create_tween().set_ease(Tween.EASE_OUT)
	move_tween.tween_property(guest, "global_position", global_position, duration)
	move_tween.parallel().tween_property(guest, "global_rotation", global_rotation, duration * 0.9)
	move_tween.finished.connect(_on_guest_movement_finished)

func _on_guest_movement_finished() -> void:
	on_guest_arrived.emit(self, guest)

func leave_mark() -> void:
	on_mark_left.emit(self, guest)
	guest = null