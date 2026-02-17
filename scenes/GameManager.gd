extends Node
class_name GameManager


@export var time_before_start: float = 0.2
@export var time_between_guest_spawns: float = 0.8


@export var lift_controller: LiftController
@export var room_manager: RoomManager
@export var guest_spawner: GuestSpawner

@export var chance_to_spawn_one_guest: float = 0.5
@export var chance_to_spawn_two_guests: float = 0.1

var floors_visited: Dictionary[int, int] = {}

var guest_spawn_timer: Timer

func _ready() -> void:
	guest_spawn_timer = Timer.new()
	guest_spawn_timer.wait_time = time_between_guest_spawns
	guest_spawn_timer.one_shot = true
	guest_spawn_timer.autostart = false
	add_child(guest_spawn_timer)

	lift_controller.on_floor_visited.connect(_on_floor_visited)
	lift_controller.on_floor_left.connect(_on_floor_left)
	lift_controller.on_doors_opened.connect(_on_doors_opened)
	lift_controller.open_doors_on_start(time_before_start)

	for i in range(lift_controller.get_floor_amount()):
		floors_visited[i] = 0

func _on_floor_visited(visited_floor: int) -> void:
	print("Floor ", visited_floor, " visited")
	floors_visited[visited_floor] = floors_visited.get(visited_floor, 0) + 1
	room_manager.arrive_at_floor(visited_floor)

func _on_floor_left(left_floor: int) -> void:
	print("Floor ", left_floor, " left")
	room_manager.leave_current_room()

func _on_doors_opened(opened_floor: int) -> void:
	print("Doors opened at floor ", opened_floor)
	_handle_guests_in_elevator(opened_floor)

func _handle_guests_in_elevator(new_floor: int) -> void:
	await guest_spawner.handle_guests_in_elevator_when_arriving_to_floor(new_floor)
	await _handle_guest_spawning()


func _handle_guest_spawning() -> void:
	var chance = randf()

	var amount: int = 0
	if chance <= chance_to_spawn_two_guests:
		amount = 2
	elif chance - chance_to_spawn_two_guests <= chance_to_spawn_one_guest or guest_spawner.current_guest_count == 0:
		amount = 1

	print("Spawning ", amount, " guests")
	for i in range(amount):
		var guest = guest_spawner.spawn_guest()
		var first_time: bool = floors_visited[guest.wanted_floor] == 0
		var icon = room_manager.get_icon_for_floor(guest.wanted_floor, first_time)
		guest.set_icon(icon)

		guest_spawn_timer.start()
		await guest_spawn_timer.timeout
	
	if amount > 0:
		guest_spawn_timer.start(time_between_guest_spawns * 2)
		await guest_spawn_timer.timeout
	
	lift_controller.make_ready()