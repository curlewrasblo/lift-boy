extends Node
class_name GuestSpawner

@export var guest_scene: PackedScene

@export var guest_move_time_on_lift_path: float = 1.2
@export var guest_move_time_on_mark: float = 0.72

@export var room_manager: RoomManager
@export var lift_controller: LiftController

@export_subgroup("Local Refs")
@export var lift_mark_parent: Node3D
@export var path_parent: Node3D
@export var guest_parent: Node3D

var available_lift_marks: Array[LiftMark] = []
var available_lift_path_queue: Array[LiftPath] = []

var spawned_guests_per_wanted_floor: Dictionary[int, Array] # Wanted floor -> List of guests
var guest_to_mark: Dictionary[Guest, LiftMark] = {}
var current_guest_count: int = 0


func _ready() -> void:
	assert(lift_mark_parent != null, "Lift mark parent is not set")
	assert(path_parent != null, "Path parent is not set")
	for child in lift_mark_parent.get_children():
		if child is LiftMark:
			available_lift_marks.append(child)
	for child in path_parent.get_children():
		if child is LiftPath:
			available_lift_path_queue.append(child)
	
	for i in range(lift_controller.get_floor_amount()):
		spawned_guests_per_wanted_floor[i] = []


func handle_guests_in_elevator_when_arriving_to_floor(new_floor: int) -> bool:
	if current_guest_count <= 0:
		print("No guests, who cares about arriving to floor ", new_floor)
		return false

	var guest_got_off_here: bool = false

	while spawned_guests_per_wanted_floor[new_floor].size() > 0:
		var guest = spawned_guests_per_wanted_floor[new_floor].pop_front()
		assert(guest != null, "Popped null guest from empty list")
		_move_guest_out_of_elevator(guest)
		guest_got_off_here = true
		await get_tree().create_timer(guest_move_time_on_lift_path * 0.8).timeout
	
	await get_tree().create_timer(guest_move_time_on_lift_path * 0.33).timeout

	if guest_got_off_here:
		print("You did good kid!")
		current_guest_count -= 1
	else:
		print("Dude wrong floor!")
	
	return guest_got_off_here


func _move_guest_out_of_elevator(guest: Guest) -> void:
	var lift_path = _get_available_lift_path()
	assert(lift_path != null, "No available lift path found")
	assert(lift_path.is_available())

	assert(lift_path.on_path_finished.is_connected(_on_exit_path_finished) == false, "Path already has a connection")
	lift_path.on_path_finished.connect(_on_exit_path_finished)

	lift_path.take_path_out_of_elevator(guest_move_time_on_lift_path, guest)

	var mark = guest_to_mark[guest]
	assert(mark != null, "Guest doesn't have a mark")
	mark.leave_mark()
	guest_to_mark.erase(guest)


func _on_exit_path_finished(path: LiftPath, guest: Guest) -> void:
	path.on_path_finished.disconnect(_on_exit_path_finished)
	available_lift_path_queue.append(path)

	_terminate_guest(guest)


func _terminate_guest(guest: Guest) -> void:
	guest.queue_free()
	#TODO: Get a point or something here! Success!


func spawn_guest() -> Guest:
	if !has_available_lift_mark():
		print("No available lift mark found, skipping guest spawn")
		return null
	
	var guest := _get_instantiated_guest()
	assert(guest != null, "Guest is not instantiated")

	var wanted_floor = randi() % lift_controller.get_activated_floor_amount()
	if wanted_floor == lift_controller.current_floor:
		wanted_floor = (wanted_floor + 2) % lift_controller.get_activated_floor_amount()
	
	guest.set_wanted_floor(wanted_floor)
	spawned_guests_per_wanted_floor[wanted_floor].append(guest)

	print("New guest wants to go to floor ", wanted_floor)

	current_guest_count += 1

	var lift_path = _get_available_lift_path()
	if lift_path == null:
		print("No available lift path found")
		return null

	assert(lift_path.is_available())

	assert(lift_path.on_path_finished.is_connected(_on_entry_path_finished) == false, "Path already has a connection")
	lift_path.on_path_finished.connect(_on_entry_path_finished)

	lift_path.take_path_into_elevator(guest_move_time_on_lift_path, guest)

	#Call dibs on Lift mark
	var available_mark = _get_available_lift_mark()
	assert(available_mark != null, "No available lift mark found")
	guest_to_mark[guest] = available_mark
	available_mark.take_mark(guest)

	return guest


func _move_guest_to_mark(guest: Guest) -> void:
	assert(guest_to_mark.has(guest), "Guest doesn't have a mark")
	var lift_mark = guest_to_mark[guest]

	assert(lift_mark.on_guest_arrived.is_connected(_on_guest_ready_at_mark) == false, "Guest already has a connection")
	lift_mark.on_guest_arrived.connect(_on_guest_ready_at_mark)
	lift_mark.walk_to_mark(guest_move_time_on_mark)


func _on_guest_ready_at_mark(mark: LiftMark, guest: Guest) -> void:
	mark.on_guest_arrived.disconnect(_on_guest_ready_at_mark)
	guest.show_icon()
	

func _on_entry_path_finished(path: LiftPath, guest: Guest) -> void:
	path.on_path_finished.disconnect(_on_entry_path_finished)
	available_lift_path_queue.append(path)
	_move_guest_to_mark(guest)


func _get_instantiated_guest() -> Guest:
	var guest = guest_scene.instantiate() as Guest
	add_child(guest)
	return guest


func has_available_lift_mark() -> bool:
	return _get_available_lift_mark() != null


func _get_available_lift_mark() -> LiftMark:
	for mark in available_lift_marks:
		if mark.is_available():
			return mark
	return null

func _get_available_lift_path() -> LiftPath:
	var available_path = available_lift_path_queue.pop_at(randi() % available_lift_path_queue.size())
	return available_path
