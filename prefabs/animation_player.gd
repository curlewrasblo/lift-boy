extends AnimationPlayer

@export var my_room : Room
@export var my_animation : StringName
@export var play_cooldown : int = 1

var plays : int = 0

func _ready() -> void:
	my_room.on_room_loaded.connect(_on_room_loaded)
	my_room.on_room_unloaded.connect(_on_room_unloaded)

func _on_room_loaded() -> void:
	if plays <= 0:
		plays = play_cooldown
		play(my_animation)
	plays -= 1

func _on_room_unloaded() -> void:
	stop()