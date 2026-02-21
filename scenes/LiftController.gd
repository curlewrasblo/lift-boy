extends Node
class_name LiftController


signal on_floor_visited(visited_floor: int)
signal on_doors_opened(opened_floor: int)
signal on_floor_left(left_floor: int)


enum LiftState {
	Ready,
	ClosingDoors,
	Moving,
	OpeningDoors
}

@export var time_to_reach_full_speed: float = 0.42
@export var time_between_floors: float = 1.0
@export var room_manager: RoomManager
@export var liftboy: Liftboy
@export_subgroup("Elevator")
@export var lift_player: LiftPlayer
@export var lift_button_parent: Node3D

@export_subgroup("Background movement")
@export var background_quad: MeshInstance3D
@export var shader_move_max_speed: float = 1.0

@export_subgroup("Camera Shake")
@export var camera: Camera3D
@export var camera_shake_intensity: Vector2 = Vector2(0.05, 0.05)
@export var camera_shake_interval: float = 0.1

var is_activated: bool = true

var movement_material: ShaderMaterial
var shake_timer: float = 0.0
var move_tween: Tween
var current_floor: int = 0

var original_camera_position: Vector3

var lift_state := LiftState.ClosingDoors
var doors_closed: bool = true
var moving_factor: float = 0.0
var lift_buttons: Array[LiftButton] = []

var uv_offset: float = 0.0
var shader_moving: float = 0.0 # Goes from -1 to 0 to 1, where -1 is lift moving down and 1 is lift moving up and 0 is at rest

var buttons: Dictionary[int, LiftButton] = {}

func _on_room_manager_ready() -> void:
	room_manager.ready.disconnect(_on_room_manager_ready)

	for button in lift_buttons:
		var icon = room_manager.get_icon_for_floor(button.my_floor, true)
		button.set_symbol(icon)

func _ready() -> void:
	movement_material = background_quad.material_override as ShaderMaterial
	assert(movement_material != null, "Movement material is not a ShaderMaterial")
	uv_offset = 0.0
	movement_material.set_shader_parameter("uv_offset", uv_offset)
	movement_material.set_shader_parameter("moving_factor", moving_factor)
	original_camera_position = camera.position
	
	var is_room_manager_ready: bool = room_manager.is_node_ready()
	if !is_room_manager_ready:
		room_manager.ready.connect(_on_room_manager_ready)

	for button in lift_button_parent.get_children():
		if button is LiftButton:
			lift_buttons.append(button)
			button.button_pressed.connect(_on_button_pressed)
			button.set_current_floor(false)
			button.set_activated(false)

			if is_room_manager_ready:
				var icon = room_manager.get_icon_for_floor(button.my_floor, true)
				button.set_symbol(icon)

			buttons[button.my_floor] = button

	buttons[current_floor].set_current_floor(true)


var is_activating_buttons: bool = false
func activate_buttons_up_to_floor(to_floor: int) -> void:
	if is_activating_buttons:
		return
	is_activating_buttons = true
	for i: int in range(lift_buttons.size()):
		var button = lift_buttons[lift_buttons.size() - i - 1]
		if button.my_floor <= to_floor and !button.is_activated:
			button.set_activated(true)
			var tween = create_tween().set_ease(Tween.EASE_IN_OUT)
			tween.tween_property(button.visual_node, "scale", Vector3.ONE * 1.5, 0.16).from(Vector3.ONE)
			tween.tween_property(button.visual_node, "scale", Vector3(1.0, 1.0, 1.0), 0.16)
			tween.play()
			await get_tree().create_timer(0.25).timeout
	is_activating_buttons = false

func get_floor_amount() -> int:
	return lift_buttons.size()

func get_activated_floor_amount() -> int:
	return lift_buttons.filter(func(button: LiftButton) -> bool: return button.is_activated).size()

func make_ready() -> void:
	assert(lift_state == LiftState.OpeningDoors, "Lift should be opening doors right now")
	print(name, ": Lift is ready at floor ", current_floor)
	lift_state = LiftState.Ready
	doors_closed = false

func make_not_ready() -> void:
	lift_state = LiftState.OpeningDoors
	
func _process(delta: float) -> void:
	if lift_state == LiftState.Moving:
		uv_offset += shader_moving * shader_move_max_speed * delta
		movement_material.set_shader_parameter("uv_offset", uv_offset)

		shake_timer += delta
		if shake_timer >= camera_shake_interval:
			shake_timer -= camera_shake_interval
			_camera_shake(moving_factor)
	elif lift_state == LiftState.Ready and is_activated:
		if Input.is_key_pressed(KEY_1):
			press_button(0)
		elif Input.is_key_pressed(KEY_2):
			press_button(1)
		elif Input.is_key_pressed(KEY_3):
			press_button(2)
		elif Input.is_key_pressed(KEY_4):
			press_button(3)
		elif Input.is_key_pressed(KEY_5):
			press_button(4)
		elif Input.is_key_pressed(KEY_6):
			press_button(5)
		elif Input.is_key_pressed(KEY_7):
			press_button(6)
		elif Input.is_key_pressed(KEY_8):
			press_button(7)


func open_doors_on_start(time_before_start: float) -> void:
	lift_state = LiftState.OpeningDoors
	doors_closed = true
	await get_tree().create_timer(time_before_start).timeout
	on_floor_visited.emit(current_floor)
	await open_doors()
	on_doors_opened.emit(current_floor)

func _on_button_pressed(button_floor: int) -> void:
	press_button(button_floor)
	liftboy.press_button(buttons[button_floor].global_position)

func deactivate() -> void:
	is_activated = false

func press_button(elevator_floor: int) -> void:
	if lift_state != LiftState.Ready:
		return
	
	if current_floor == elevator_floor:
		return
	
	if !is_activated or !buttons[elevator_floor].is_activated:
		return

	buttons[elevator_floor].set_pressed(true)
	
	if !doors_closed:
		print(name, ": Closing doors")
		lift_state = LiftState.ClosingDoors
		await close_doors()
		doors_closed = true

	if elevator_floor == 7:
		deactivate()
	
	on_floor_left.emit(current_floor)
	lift_state = LiftState.Moving
	print(name, ": Moving to floor ", elevator_floor)
	await move_to_floor(elevator_floor)
	on_floor_visited.emit(elevator_floor)
	lift_state = LiftState.OpeningDoors
	print(name, ": Opening doors")
	await open_doors()
	on_doors_opened.emit(elevator_floor)


func close_doors() -> void:
	lift_player.close_doors()

	AudioManager.play_lift_doors_close()
	await lift_player.animation_finished

func open_doors() -> void:
	lift_player.open_doors()

	AudioManager.play_lift_doors_open()
	await lift_player.animation_finished


func move_to_floor(to_floor: int) -> void:
	assert(lift_state == LiftState.Moving, "Lift shouldnt be moving right now")
	if move_tween != null:
		move_tween.kill()
		move_tween = null

	var target = 1.0 if to_floor > current_floor else -1.0
	var floors_to_move = abs(to_floor - current_floor)

	var travel_time = 0.0
	move_tween = create_tween()
	move_tween.tween_method(_on_move_process, 0.0, target, time_to_reach_full_speed).set_ease(Tween.EASE_IN)
	travel_time += time_to_reach_full_speed
	for i: int in range(floors_to_move):
		var interval = time_between_floors
		if i == 0:
			interval -= time_to_reach_full_speed / 2.0
		var interval_tween = move_tween.tween_interval(interval)
		travel_time += interval
		interval_tween.finished.connect(func(): _set_new_floor(current_floor + 1 * target))

	move_tween.tween_method(_on_move_process, target, 0.0, time_to_reach_full_speed).set_ease(Tween.EASE_OUT)
	travel_time += time_to_reach_full_speed
	AudioManager.play_lift_move(time_to_reach_full_speed, travel_time)

	await move_tween.finished
	_lift_ready_at_new_floor(to_floor)

func _on_move_process(factor: float) -> void:
	moving_factor = abs(factor)
	movement_material.set_shader_parameter("moving_factor", moving_factor)

	shader_moving = factor

func _set_new_floor(new_floor: int) -> void:
	buttons[current_floor].set_current_floor(false)
	buttons[new_floor].set_current_floor(true)
	current_floor = new_floor

func _lift_ready_at_new_floor(new_floor: int) -> void:
	moving_factor = 0.0
	movement_material.set_shader_parameter("moving_factor", moving_factor)
	shake_timer = 0.0
	shader_moving = 0.0
	camera.position = original_camera_position

	_set_new_floor(new_floor)

func _camera_shake(factor: float) -> void:
	var intensity = pow(factor, 2) * camera_shake_intensity
	camera.position = original_camera_position + Vector3(randf_range(-intensity.x, intensity.x), randf_range(-intensity.y, intensity.y), 0.0)
