extends Node
class_name RoomManager

@export var all_rooms: Array[Room]
@export var icons_per_room: Array[Texture2D]
@export var icons_per_floor: Array[Texture2D]

var room_for_floor: Dictionary[int, Room] = {}

var current_room: Room = null

func _ready() -> void:
	_init_rooms()

func _init_rooms() -> void:
	var available_rooms = all_rooms.duplicate()
	room_for_floor[0] = available_rooms[0]
	room_for_floor[7] = available_rooms[available_rooms.size() - 1]
	available_rooms.remove_at(0)
	available_rooms.remove_at(available_rooms.size() - 1)

	for i: int in range(1, all_rooms.size() - 1):
		var random_index = randi() % (available_rooms.size())
		room_for_floor[i] = available_rooms[random_index]
		available_rooms.remove_at(random_index)

func arrive_at_floor(to_floor: int) -> void:
	assert(room_for_floor.has(to_floor), "Room for floor %s not found" % to_floor)
	if current_room != null:
		current_room.unload_room()
	current_room = room_for_floor[to_floor]
	current_room.load_room()

func leave_current_room() -> void:
	if current_room != null:
		current_room.unload_room()
		current_room = null

func get_icon_for_floor(wanted_floor: int, first_time: bool) -> Texture2D:
	assert(room_for_floor.has(wanted_floor), "Room for floor %s not found" % wanted_floor)
	var index = all_rooms.find(room_for_floor[wanted_floor])
	assert(index != -1, "Index not found")
	assert(icons_per_room.size() > index, "Not enough icons set up. Index %s is out of bounds" % index)
	assert(icons_per_floor.size() > index, "Not enough icons set up. Index %s is out of bounds" % wanted_floor)

	if first_time:
		return icons_per_floor[wanted_floor]
	return icons_per_room[index]
