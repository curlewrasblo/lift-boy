extends Node
class_name LiftController

enum LiftState {
	Ready,
	ClosingDoors,
	Moving,
	OpeningDoors
}

@export var time_to_reach_full_speed: float = 0.42
@export var time_between_floors: float = 1.0

@export_subgroup("Elevator")
@export var lift_player: LiftPlayer

@export_subgroup("Background movement")
@export var background_quad: MeshInstance3D
@export var shader_move_max_speed: float = 1.0

@export_subgroup("Camera Shake")
@export var camera: Camera3D
@export var camera_shake_intensity: Vector2 = Vector2(0.05, 0.05)
@export var camera_shake_interval: float = 0.1

var movement_material: ShaderMaterial
var shake_timer: float = 0.0
var move_tween: Tween
var current_floor: int = 0

var original_camera_position: Vector3

var lift_state := LiftState.Ready
var doors_closed: bool = true
var moving_factor: float = 0.0

var uv_offset: float = 0.0
var shader_moving: float = 0.0 # Goes from -1 to 0 to 1, where -1 is lift moving down and 1 is lift moving up and 0 is at rest

func _ready() -> void:
	movement_material = background_quad.material_override as ShaderMaterial
	assert(movement_material != null, "Movement material is not a ShaderMaterial")
	uv_offset = 0.0
	movement_material.set_shader_parameter("uv_offset", uv_offset)
	movement_material.set_shader_parameter("moving_factor", moving_factor)
	original_camera_position = camera.position


func _process(delta: float) -> void:
	if lift_state == LiftState.Moving:
		uv_offset += shader_moving * shader_move_max_speed * delta
		movement_material.set_shader_parameter("uv_offset", uv_offset)

		shake_timer += delta
		if shake_timer >= camera_shake_interval:
			shake_timer -= camera_shake_interval
			_camera_shake(moving_factor)
	elif lift_state == LiftState.Ready:
		if Input.is_key_pressed(KEY_0):
			press_button(0)
		elif Input.is_key_pressed(KEY_1):
			press_button(1)
		elif Input.is_key_pressed(KEY_2):
			press_button(2)
		elif Input.is_key_pressed(KEY_3):
			press_button(3)
		elif Input.is_key_pressed(KEY_4):
			press_button(4)


func press_button(elevator_floor: int) -> void:
	if lift_state != LiftState.Ready:
		return
	
	if current_floor == elevator_floor:
		return
	
	if !doors_closed:
		print(name, ": Closing doors")
		lift_state = LiftState.ClosingDoors
		await close_doors()
		doors_closed = true
	
	lift_state = LiftState.Moving
	print(name, ": Moving to floor ", elevator_floor)
	await move_to_floor(elevator_floor)
	lift_state = LiftState.OpeningDoors
	print(name, ": Opening doors")
	await open_doors()
	doors_closed = false
	lift_state = LiftState.Ready
	print(name, ": Lift is ready at floor ", elevator_floor)


func close_doors() -> void:
	lift_player.close_doors()
	await lift_player.animation_finished

func open_doors() -> void:
	lift_player.open_doors()
	await lift_player.animation_finished


func move_to_floor(to_floor: int) -> void:
	assert(lift_state == LiftState.Moving, "Lift shouldnt be moving right now")
	if move_tween != null:
		move_tween.kill()
		move_tween = null

	var target = 1.0 if to_floor > current_floor else -1.0
	var floors_to_move = abs(to_floor - current_floor)

	move_tween = create_tween()
	move_tween.tween_method(_on_move_process, 0.0, target, time_to_reach_full_speed).set_ease(Tween.EASE_IN)
	move_tween.tween_interval(time_between_floors * floors_to_move)
	move_tween.tween_method(_on_move_process, target, 0.0, time_to_reach_full_speed).set_ease(Tween.EASE_OUT)

	await move_tween.finished
	_lift_ready_at_new_floor(to_floor)

func _on_move_process(factor: float) -> void:
	moving_factor = abs(factor)
	movement_material.set_shader_parameter("moving_factor", moving_factor)

	shader_moving = factor

func _lift_ready_at_new_floor(new_floor: int) -> void:
	current_floor = new_floor
	moving_factor = 0.0
	movement_material.set_shader_parameter("moving_factor", moving_factor)
	shake_timer = 0.0
	shader_moving = 0.0
	camera.position = original_camera_position

func _camera_shake(factor: float) -> void:
	var intensity = factor * camera_shake_intensity
	camera.position = original_camera_position + Vector3(randf_range(-intensity.x, intensity.x), randf_range(-intensity.y, intensity.y), 0.0)
