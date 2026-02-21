extends Node

@export var sound_lift_press : AudioStreamPlayer
@export var sound_lift_doors_open : AudioStreamPlayer
@export var sound_lift_doors_close : AudioStreamPlayer
@export var sound_lift_move : AudioStreamPlayer

@export var sound_guest_speak: AudioStreamPlayer
@export var sound_guest_kill: AudioStreamPlayer


func play_lift_press() -> void:
	sound_lift_press.play()

func play_lift_doors_open() -> void:
	sound_lift_doors_open.play()

func play_lift_doors_close() -> void:
	sound_lift_doors_close.play()

func play_guest_speak() -> void:
	sound_guest_speak.play()

func play_guest_kill() -> void:
	sound_guest_kill.play()

func play_lift_move(time_to_max_speed :float, travel_time :float) -> void:
	var tween = create_tween()
	tween.tween_property(sound_lift_move, "pitch_scale", 1.0, time_to_max_speed).set_ease(Tween.EASE_IN).from(0.5)
	tween.tween_interval(travel_time - time_to_max_speed * 2)
	tween.tween_property(sound_lift_move, "pitch_scale", 0.5, time_to_max_speed).set_ease(Tween.EASE_IN)
	sound_lift_move.play()

	await tween.finished
	sound_lift_move.stop()
