extends Node
class_name GameManager


@export var time_before_start: float = 0.2
@export var time_between_guest_spawns: float = 0.8


@export var lift_controller: LiftController
@export var room_manager: RoomManager
@export var guest_spawner: GuestSpawner
@export var vibe_manager: VibeManager

@export var chance_to_spawn_one_guest: float = 0.5
@export var chance_to_spawn_two_guests: float = 0.1

@export_subgroup("Progression Thresholds")
@export var show_complicated_icons_threshold: int = 3
@export var two_guest_spawn_threshold: int = 6
@export var buttons_five_to_seven: int = 12


var floors_visited: Dictionary[int, int] = {}

var guest_spawn_timer: Timer

var progression: int = 0

var is_defeated: bool = false
var is_victorious: bool = false

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

	vibe_manager.on_defeated.connect(_on_vibe_defeated)
	vibe_manager.on_victory.connect(_on_vibe_victory)

	for i in range(lift_controller.get_floor_amount()):
		floors_visited[i] = 0

func _on_vibe_defeated() -> void:
	is_defeated = true
	print("Vibe defeated")
	_face_defeat()


func _on_vibe_victory() -> void:
	print("Vibe victory")
	is_victorious = true
	lift_controller.activate_buttons_up_to_floor(999)

func _on_floor_visited(visited_floor: int) -> void:
	print("Floor ", visited_floor, " visited")
	floors_visited[visited_floor] += 1
	room_manager.arrive_at_floor(visited_floor)

	if floors_visited[visited_floor] <= 2:
		increase_progression(1)

func _on_floor_left(left_floor: int) -> void:
	print("Floor ", left_floor, " left")
	room_manager.leave_current_room()

func _face_defeat() -> void:
	print(name, ": Uh oh defeat time!")
	lift_controller.make_not_ready()
	await lift_controller.close_doors()
	#TODO: Make dude chomp liftboy

	await get_tree().create_timer(3.0).timeout

	get_tree().reload_current_scene()


func _on_doors_opened(opened_floor: int) -> void:
	print("Doors opened at floor ", opened_floor)
	if is_defeated:
		return
	
	_handle_guests_in_elevator(opened_floor)

func _handle_guests_in_elevator(new_floor: int) -> void:
	var good_floor_for_a_guest: bool = await guest_spawner.handle_guests_in_elevator_when_arriving_to_floor(new_floor)
	if good_floor_for_a_guest:
		increase_progression(1)
	
	await _handle_guest_spawning()


func increase_progression(by_amount: int) -> void:
	progression += by_amount
	print("Progression: ", progression)
	if progression >= buttons_five_to_seven:
		lift_controller.activate_buttons_up_to_floor(7)


func _handle_guest_spawning() -> void:
	if guest_spawner.current_guest_count >= 3 or is_victorious:
		lift_controller.make_ready()
		return
	
	var chance = randf()

	var amount: int = 0
	if chance <= chance_to_spawn_two_guests and progression >= two_guest_spawn_threshold and guest_spawner.current_guest_count < 2:
		amount = 2
	elif chance - chance_to_spawn_two_guests <= chance_to_spawn_one_guest or guest_spawner.current_guest_count == 0:
		amount = 1
		if guest_spawner.current_guest_count >= 2:
			if randf() < 0.75:
				amount = 0


	print("Spawning ", amount, " guests")
	for i in range(amount):
		if !guest_spawner.has_available_lift_mark():
			break
		var guest = guest_spawner.spawn_guest()
		var first_time: bool = floors_visited[guest.wanted_floor] == 0 or progression < show_complicated_icons_threshold
		var icon = room_manager.get_icon_for_floor(guest.wanted_floor, first_time)
		guest.set_icon(icon)

		guest_spawn_timer.start()
		await guest_spawn_timer.timeout
	
	if amount > 0:
		guest_spawn_timer.start(time_between_guest_spawns * 2)
		await guest_spawn_timer.timeout
	
	lift_controller.make_ready()
