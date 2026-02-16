extends AnimationPlayer
class_name LiftPlayer

@export var open_door_anim: StringName
#@export var close_door_anim: StringName

func open_doors() -> void:
	play(open_door_anim)

func close_doors() -> void:
	play_backwards(open_door_anim)
