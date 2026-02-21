extends Node3D
class_name Guest


@export var icon_display: MeshInstance3D
@export var icon_movement: Vector3 = Vector3.UP * 0.2
@export var icon_tween_duration: float = 2.2

@export var elevator_mesh: MeshInstance3D
@export var floor_mesh: MeshInstance3D

@export var shake_node: Node3D

@export var elevator_shake_intensity: Vector2 = Vector2(0.05, 0.05)
@export var shake_mad_duration: float = 0.5
@export var shake_mad_interval: float = 0.1
@export var fade_duration: float = 0.5

@export var area_3d: Area3D

var wanted_floor: int = -1
var floors_travelled_to: int = 0

var icon_material: ShaderMaterial
var icon_to_show: Texture2D = null

var icon_tween: Tween = null

var origincal_icon_pos: Vector3 = Vector3.ZERO

var is_selected: bool = false
var is_layer_elevator: bool = false

var fade_tween: Tween = null
var shake_mad_tween: Tween = null
var shake_mad_last_index: int = -1

var elevator_material: ShaderMaterial
var floor_material: ShaderMaterial
var original_elevator_mesh_position: Vector3
func _ready() -> void:
	assert(icon_display != null, "Icon display is not set")
	icon_material = icon_display.material_override as ShaderMaterial
	assert(icon_material != null, "Icon material is not a ShaderMaterial")
	origincal_icon_pos = icon_display.position

	assert(elevator_mesh != null, "Elevator mesh is not set")
	original_elevator_mesh_position = elevator_mesh.position
	elevator_material = elevator_mesh.get_active_material(0) as ShaderMaterial
	assert(elevator_material != null, "Elevator material is not a ShaderMaterial")

	floor_material = floor_mesh.get_active_material(0) as ShaderMaterial
	assert(floor_material != null, "Floor material is not a ShaderMaterial")

	icon_display.visible = false

	area_3d.mouse_entered.connect(_on_mouse_entered)
	area_3d.mouse_exited.connect(_on_mouse_exited)

func _process(_delta: float) -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and is_selected and is_layer_elevator:
		show_icon()

func _on_mouse_entered() -> void:
	is_selected = true

func _on_mouse_exited() -> void:
	is_selected = false


func set_wanted_floor(to_floor: int) -> void:
	assert(wanted_floor == -1, "Wanted floor is already set")
	wanted_floor = to_floor


func set_icon(icon: Texture2D) -> void:
	icon_to_show = icon


func show_icon() -> void:
	if icon_display.visible:
		return
	assert(icon_to_show != null, "Icon to show is not set")
	icon_material.set_shader_parameter("icon_texture", icon_to_show)

	if icon_tween != null:
		icon_tween.kill()
		icon_tween = null

	icon_display.visible = true
	icon_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	icon_tween.tween_method(_icon_progress, 0.0, 1.0, icon_tween_duration)
	icon_tween.finished.connect(_on_icon_tween_finished)

func _icon_progress(factor: float) -> void:
	var fade_in_factor = clampf(factor / 0.25, 0.0, 1.0)
	var fade_out_factor = 1.0 - clampf((factor - 0.985) / 0.015, 0.0, 1.0)

	icon_display.position = origincal_icon_pos + icon_movement * factor

	icon_material.set_shader_parameter("icon_opacity", fade_in_factor * fade_out_factor)


func _on_icon_tween_finished() -> void:
	icon_display.visible = false
	icon_material.set_shader_parameter("icon_opacity", 0.0)
	icon_display.position = origincal_icon_pos


func set_layer_new_floor() -> void:
	if fade_tween != null:
		fade_tween.kill()
		fade_tween = null
	is_layer_elevator = false
	fade_tween = create_tween().set_ease(Tween.EASE_IN_OUT)
	fade_tween.tween_property(floor_material, "shader_parameter/opacity", 1.0, fade_duration / 2.0).from(0.0)
	fade_tween.tween_property(elevator_material, "shader_parameter/opacity", 0.0, fade_duration / 2.0).from(1.0)

func set_layer_elevator() -> void:
	if fade_tween != null:
		fade_tween.kill()
		fade_tween = null
	is_layer_elevator = true
	fade_tween = create_tween().set_ease(Tween.EASE_IN_OUT)
	fade_tween.tween_property(elevator_material, "shader_parameter/opacity", 1.0, fade_duration / 2.0).from(0.0)
	fade_tween.tween_property(floor_material, "shader_parameter/opacity", 0.0, fade_duration / 2.0).from(1.0)


func travelled_to_new_wrong_floor() -> bool:
	floors_travelled_to += 1
	if floors_travelled_to >= 3:
		shake_mad()
		return true
	return false

func shake_mad() -> void:
	if shake_mad_tween != null:
		shake_mad_tween.kill()
		shake_mad_tween = null

	shake_mad_last_index = -1
	shake_mad_tween = create_tween().set_ease(Tween.EASE_IN_OUT)
	shake_mad_tween.tween_method(_on_shake_mad_progress, 0.0, 1.0, shake_mad_duration)
	shake_mad_tween.finished.connect(_on_shake_mad_finished)

func _on_shake_mad_progress(factor: float) -> void:
	var shake_interval_factor = shake_mad_interval / shake_mad_duration
	var should_shake := false
	if shake_interval_factor <= 0.0:
		should_shake = true
	else:
		var current_index = int(factor / shake_interval_factor)
		should_shake = current_index > shake_mad_last_index
		if should_shake:
			shake_mad_last_index = current_index
	if should_shake:
		var intensity = pow(factor, 2) * elevator_shake_intensity
		shake_node.position = Vector3(randf_range(-intensity.x, intensity.x), randf_range(-intensity.y, intensity.y), 0.0)

func _on_shake_mad_finished() -> void:
	shake_mad_tween = null
	shake_node.position = Vector3.ZERO