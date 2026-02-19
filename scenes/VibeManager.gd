extends Node
class_name VibeManager

signal on_defeated()
signal on_victory()

@export var start_value: float = 20.0
@export var progress_group: CanvasItem
@export var vibe_progress_bar: ProgressBar
@export var bar_move_speed: float = 1.0

@export var guest_spawner: GuestSpawner

var bar_tween: Tween
var game_over_tween: Tween

var current_vibe: float

func _ready() -> void:
	assert(vibe_progress_bar != null, "Vibe progress bar is not set")
	current_vibe = start_value
	vibe_progress_bar.value = current_vibe
	guest_spawner.on_stopped_at_correct_floor.connect(_on_guest_stopped_at_correct_floor)
	guest_spawner.on_stopped_at_wrong_floor.connect(_on_guest_stopped_at_wrong_floor)


func _on_guest_stopped_at_correct_floor() -> void:
	var to_value = current_vibe + 8.0
	_adjust_vibe_to(to_value)

func _on_guest_stopped_at_wrong_floor() -> void:
	var to_value = current_vibe - 25.0
	_adjust_vibe_to(to_value)


func _adjust_vibe_to(to_value: float) -> void:
	if current_vibe <= 0.0 or current_vibe >= 100.0:
		return

	if to_value < 0.0:
		to_value = 0.0
	elif to_value > 100.0:
		to_value = 100.0

	if bar_tween != null:
		bar_tween.kill()
		bar_tween = null

	var old_vibe = current_vibe
	var distance = abs(to_value - old_vibe)
	bar_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	bar_tween.tween_property(vibe_progress_bar, "value", to_value, distance / bar_move_speed).from(old_vibe)
	bar_tween.tween_callback(_on_bar_tween_finished)
	current_vibe = to_value


func _on_bar_tween_finished() -> void:
	if current_vibe <= 0.0:
		on_defeated.emit()
		_fade_out_progress_group()
	elif current_vibe >= 100.0:
		on_victory.emit()
		_fade_out_progress_group()


func _fade_out_progress_group() -> void:
	if game_over_tween != null:
		game_over_tween.kill()
		game_over_tween = null

	game_over_tween = create_tween()
	game_over_tween.tween_interval(1.5)
	game_over_tween.tween_callback(_on_game_over_tween_finished)

func _on_game_over_tween_finished() -> void:
	progress_group.visible = false