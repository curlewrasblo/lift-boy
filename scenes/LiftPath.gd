extends Path3D
class_name LiftPath

signal on_path_finished(sender: LiftPath, guest: Guest)

@export var remote_transform: RemoteTransform3D
@export var follower: PathFollow3D

var guest: Guest = null
var move_tween: Tween

func _ready() -> void:
	assert(remote_transform != null, "Remote transform is not set")
	assert(follower != null, "Follower is not set")

func is_available() -> bool:
	return guest == null

func take_path_into_elevator(duration: float, node_to_follow: Guest) -> void:
	assert(is_available(), "Path is not available")
	guest = node_to_follow
	guest.set_layer_new_floor()
	remote_transform.remote_path = remote_transform.get_path_to(node_to_follow)

	follower.use_model_front = false
	_handle_path_follower(1.0, 0.0, duration)

func take_path_out_of_elevator(duration: float, node_to_follow: Guest) -> void:
	assert(is_available(), "Path is not available")

	guest = node_to_follow
	follower.use_model_front = true
	follower.progress_ratio = 0.0

	await _handle_guest_getting_to_path(duration * 0.2)
	guest.set_layer_new_floor()
	remote_transform.remote_path = remote_transform.get_path_to(node_to_follow)
	_handle_path_follower(0.0, 1.0, duration)


func _handle_guest_getting_to_path(duration: float) -> void:
	assert(guest != null, "Guest should be set")

	var target_position = follower.global_position

	if move_tween != null:
		move_tween.kill()
		move_tween = null

	guest.play_walk_animation(1.4)

	move_tween = create_tween()
	move_tween.tween_property(guest, "global_position", target_position, duration).set_ease(Tween.EASE_IN)
	move_tween.play()
	await move_tween.finished


func _handle_path_follower(from: float, to: float, duration: float) -> void:
	if move_tween != null:
		move_tween.kill()
		move_tween = null

	follower.progress_ratio = from
	guest.play_walk_animation(2.1)

	move_tween = create_tween()
	move_tween.tween_property(follower, "progress_ratio", to, duration).set_ease(Tween.EASE_IN)
	move_tween.finished.connect(_on_move_tween_finished)

func _on_move_tween_finished() -> void:
	guest.set_layer_elevator()
	remote_transform.remote_path = NodePath("")
	on_path_finished.emit(self, guest)
	guest = null
