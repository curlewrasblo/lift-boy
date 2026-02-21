extends Node3D
class_name LiftButton

signal button_pressed(floor: int)

@export var button_body: StaticBody3D
@export var movement: float = 0.1
@export var my_floor: int = 0
@export var current_floor_node: Node3D
@export var pressed_button_node: Node3D
@export var visual_node: Node3D
@export var vfx: GPUParticles3D
@export var symbol_mesh: MeshInstance3D

var was_pressed: bool = false

var is_selected: bool = false

var original_z: float

var is_activated: bool = false

var pressed_timer: float = 0.0


var symbol_material: ShaderMaterial

func _ready() -> void:
	button_body.mouse_entered.connect(_on_mouse_entered)
	button_body.mouse_exited.connect(_on_mouse_exited)
	set_current_floor(false)
	symbol_material = symbol_mesh.material_override as ShaderMaterial
	assert(symbol_material != null, "Symbol material is not a ShaderMaterial")

	original_z = visual_node.position.z


func _process(delta: float) -> void:
	if !is_activated:
		return

	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and !was_pressed and is_selected:
		_button_was_pressed()
	elif was_pressed:
		pressed_timer -= delta
		if pressed_timer <= 0.0:
			_reset_button()

func set_activated(activated: bool) -> void:
	is_activated = activated
	visible = is_activated

func set_pressed(active: bool) -> void:
	pressed_button_node.visible = active

func set_current_floor(active: bool) -> void:
	current_floor_node.visible = active
	set_pressed(false)

func set_symbol(symbol: Texture2D) -> void:
	symbol_material.set_shader_parameter("icon_texture", symbol)
	symbol_material.set_shader_parameter("icon_opacity", 1.0)

func _on_mouse_entered() -> void:
	if !is_activated:
		return
	is_selected = true

func _on_mouse_exited() -> void:
	if !is_activated:
		return
	is_selected = false

func _button_was_pressed() -> void:
	if was_pressed:
		return
	visual_node.position.z = original_z + movement
	was_pressed = true
	button_pressed.emit(my_floor)
	pressed_timer = 0.12
	if !vfx.emitting:
		vfx.emitting = true

func _reset_button() -> void:
	visual_node.position.z = original_z

	if !Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		was_pressed = false
