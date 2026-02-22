extends Node3D
class_name RedRoom

@export var small_sphere_parent : Node3D
@export var big_sphere : Node3D

@export var osc_amplitude : float = 0.08
@export var osc_speed : float = 2.0

var small_spheres : Array[Node3D] = []
var sphere_base_positions : Array[Vector3] = []
var timer : float = 0.0
var osc_time : float = 0.0

var big_sphere_base_position : Vector3 = Vector3.ZERO

func _ready() -> void:
	big_sphere_base_position = big_sphere.position
	for child in small_sphere_parent.get_children():
		if child is Node3D:
			small_spheres.append(child)
			sphere_base_positions.append(child.position)

func _process(delta: float) -> void:
	if !is_visible_in_tree():
		return
	
	osc_time += delta
	for i in small_spheres.size():
		var t := _oscillate_algorithm(i)
		var low_y := sphere_base_positions[i].y - osc_amplitude
		var high_y := sphere_base_positions[i].y + osc_amplitude
		small_spheres[i].position = Vector3(sphere_base_positions[i].x, lerp(low_y, high_y, t), sphere_base_positions[i].z)

	var big_sphere_t := _oscillate_algorithm(0, osc_speed * 0.5)
	big_sphere.position = big_sphere_base_position + Vector3(0, osc_amplitude * 0.5 * big_sphere_t, 0.0)

func _oscillate_algorithm(index: int, custom_speed: float = osc_speed) -> float:
	return (sin(osc_time * custom_speed + index * 0.5) + 1.0) * 0.5