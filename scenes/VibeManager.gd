extends Node
class_name VibeManager

signal on_defeated()
signal on_victory()

@export var start_value: float = 3
@export var progress_group: CanvasItem
@export var vibe_progress_bar: ProgressBarKnower
@export var bar_move_speed: float = 1.0
@export var new_score_showers: Array[NewScoreShowing] = []

@export var level_1_vibe_max_value: float = 35
@export var level_2_vibe_max_value: float = 50

@export var guest_spawner: GuestSpawner

var bar_tween: Tween
var game_over_tween: Tween

var score_pool: Array[NewScoreShowing] = []

var current_vibe: float = -1

func _ready() -> void:
	assert(vibe_progress_bar != null, "Vibe progress bar is not set")
	guest_spawner.on_stopped_at_correct_floor.connect(_on_guest_stopped_at_correct_floor)
	guest_spawner.on_stopped_at_wrong_floor.connect(_on_guest_stopped_at_wrong_floor)

	for new_score_shower in new_score_showers:
		new_score_shower.on_finished.connect(_on_new_score_shower_finished)
		score_pool.append(new_score_shower)
	
	_reset_vibe()


func _handle_start_of_current_level() -> void:
	if ProgressionSystem.current_level == 1:
		vibe_progress_bar.max_value = level_1_vibe_max_value
	elif ProgressionSystem.current_level == 2:
		vibe_progress_bar.max_value = level_2_vibe_max_value
	

func _reset_vibe() -> void:
	_handle_start_of_current_level()
	current_vibe = 1
	vibe_progress_bar.value = current_vibe
	_adjust_vibe_to(start_value)


func _on_guest_stopped_at_correct_floor(guest_count: int) -> void:
	var to_value = current_vibe + 5.0 * guest_count
	_adjust_vibe_to(to_value)

func _on_guest_stopped_at_wrong_floor() -> void:
	var to_value = current_vibe - 15.0
	_adjust_vibe_to(to_value)


func _adjust_vibe_to(to_value: float) -> void:
	if current_vibe <= 0.0 or current_vibe >= vibe_progress_bar.max_value:
		return

	if to_value < 0.0:
		to_value = 0.0
	elif to_value > vibe_progress_bar.max_value:
		to_value = vibe_progress_bar.max_value

	if bar_tween != null:
		bar_tween.kill()
		bar_tween = null

	var old_vibe = current_vibe
	var distance = abs(to_value - old_vibe)
	bar_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	bar_tween.tween_property(vibe_progress_bar, "value", to_value, distance / bar_move_speed).from(old_vibe)
	bar_tween.tween_callback(_on_bar_tween_finished)
	current_vibe = to_value

	_display_text_for_point_change(to_value - old_vibe)

func _display_text_for_point_change(point_change: int) -> void:
	if score_pool.size() > 0:
		var score_shower = score_pool.pop_front()
		score_shower.give_vibe_points(point_change)

func _on_bar_tween_finished() -> void:
	if current_vibe <= 0.0:
		on_defeated.emit()
		_fade_out_progress_group()
	elif current_vibe >= vibe_progress_bar.max_value:
		if ProgressionSystem.current_level == 1:
			ProgressionSystem.increase_level()
			_reset_vibe()
		else:
			on_victory.emit()
			_fade_out_progress_group()


func _on_new_score_shower_finished(score_shower: NewScoreShowing) -> void:
	score_pool.append(score_shower)


func _fade_out_progress_group() -> void:
	if game_over_tween != null:
		game_over_tween.kill()
		game_over_tween = null

	game_over_tween = create_tween()
	game_over_tween.tween_interval(1.5)
	game_over_tween.tween_callback(_on_game_over_tween_finished)

func _on_game_over_tween_finished() -> void:
	progress_group.visible = false
