extends Node

const CORRECT_ANSWERS_TO_KILL := 3
const QUIZ_STAMINA_COST := 5.0

var _ui: CanvasLayer
var _enemy: Node
var _player: Node
var _topic_id: int = 4
var _current_question: Dictionary
var _question_count: int = 0
var _correct_count: int = 0
var _damage_per_correct: float = 0.0
var _awaiting_continue: bool = false
var _awaiting_result_dismiss: bool = false
var _battle_won: bool = false
var _battle_over: bool = false
var _battle_active: bool = false
var _camera_original_zoom: Vector2 = Vector2.ONE
var _camera_original_offset: Vector2 = Vector2.ZERO
var _camera_original_position_y: float = 0.0

const BATTLE_ZOOM := Vector2(2.2, 2.2)
const CAMERA_TWEEN_TIME := 0.4
const ENEMY_DEATH_DELAY := 1.0

# Persists across all battles in a level so questions don't repeat
var _level_used: Dictionary = {}  # topic_id -> Array[int]

signal battle_ended(won: bool, correct: int, total: int)

func is_active() -> bool:
	return _battle_active

func _ready():
	_ui = preload("res://scripts/battle_ui.gd").new()
	_ui.visible = false
	_ui.answer_chosen.connect(_on_answer_chosen)
	_ui.continue_pressed.connect(_on_continue_pressed)
	add_child(_ui)

func reset_session():
	_level_used.clear()

func _get_used(topic_id: int) -> Array:
	if not _level_used.has(topic_id):
		_level_used[topic_id] = []
	return _level_used[topic_id]

func start_battle(enemy: Node, topic_id: int):
	if _battle_active:
		return
	_battle_active = true
	_enemy = enemy
	_player = Globals.player
	_player.frozen = true
	if not _player.died.is_connected(_on_player_died_external):
		_player.died.connect(_on_player_died_external)
	if _enemy.has_method("turn_to_player"):
		_enemy.turn_to_player()
	_freeze_enemy(true)
	_zoom_camera_in()
	_topic_id = topic_id
	_question_count = 0
	_correct_count = 0
	_damage_per_correct = ceil(float(_enemy.max_hp) / float(CORRECT_ANSWERS_TO_KILL))
	_battle_over = false
	_battle_won = false
	_awaiting_continue = false
	_awaiting_result_dismiss = false
	_ui.visible = true
	_ask_next_question()

func _zoom_camera_in():
	if not is_instance_valid(_player) or not is_instance_valid(_player.camera):
		return
	var cam: Camera2D = _player.camera
	cam.make_current()
	_camera_original_zoom = cam.zoom
	_camera_original_offset = cam.offset
	_camera_original_position_y = cam.position.y
	# Push the framing roughly halfway toward the enemy so both fit on-screen.
	var midpoint_offset: Vector2 = (_enemy.global_position - _player.global_position) * 0.5
	var tw := create_tween().set_parallel(true).set_ease(Tween.EASE_OUT)
	tw.tween_property(cam, "zoom", BATTLE_ZOOM, CAMERA_TWEEN_TIME)
	tw.tween_property(cam, "offset", midpoint_offset, CAMERA_TWEEN_TIME)
	# Cancel any level-exploration camera offset; nudge 10 px up for nicer framing.
	tw.tween_property(cam, "position:y", -10.0, CAMERA_TWEEN_TIME)

func _zoom_camera_out():
	if not is_instance_valid(_player) or not is_instance_valid(_player.camera):
		return
	var cam: Camera2D = _player.camera
	var tw := create_tween().set_parallel(true).set_ease(Tween.EASE_OUT)
	tw.tween_property(cam, "zoom", _camera_original_zoom, CAMERA_TWEEN_TIME)
	tw.tween_property(cam, "offset", _camera_original_offset, CAMERA_TWEEN_TIME)
	tw.tween_property(cam, "position:y", _camera_original_position_y, CAMERA_TWEEN_TIME)

func _freeze_enemy(freeze: bool):
	if not is_instance_valid(_enemy):
		return
	var fsm := _enemy.get_node_or_null("FiniteStateMachine")
	if fsm:
		fsm.set_process(not freeze)
		fsm.set_physics_process(not freeze)
	_enemy.velocity = Vector2.ZERO
	_enemy.set_physics_process(not freeze)

func _on_player_died_external(_place_tomb: bool = true):
	if not _battle_active:
		return
	# Player died outside the battle flow (hazard, etc.) — force-close the UI.
	_battle_active = false
	_awaiting_continue = false
	_awaiting_result_dismiss = false
	_ui.visible = false
	_zoom_camera_out()
	if is_instance_valid(_enemy):
		_enemy.in_battle = false
		_freeze_enemy(false)

func _ask_next_question():
	_question_count += 1
	_ui.reset_for_next_question()
	var difficulty: String = "hard" if _enemy.is_boss else ""
	_current_question = QuestionBank.get_question(_topic_id, _get_used(_topic_id), difficulty)
	_ui.setup_question(
		_current_question,
		_question_count,
		_player.Stats.current_hp,
		_player.Stats.max_hp,
		CORRECT_ANSWERS_TO_KILL - _correct_count,
		CORRECT_ANSWERS_TO_KILL,
		_enemy.name,
		QuestionBank.topic_names[_topic_id]
	)

func _on_answer_chosen(index: int):
	if _awaiting_continue or _awaiting_result_dismiss:
		return
	var correct: bool = (index == _current_question.correct)
	if correct:
		_apply_correct_answer()
	else:
		_apply_wrong_answer()
	_ui.update_hp_bars(
		_player.Stats.current_hp,
		_player.Stats.max_hp,
		CORRECT_ANSWERS_TO_KILL - _correct_count,
		CORRECT_ANSWERS_TO_KILL
	)
	_ui.show_feedback(correct, _current_question.correct, _current_question.explanation)
	_awaiting_continue = true

func _apply_correct_answer():
	_correct_count += 1
	if _player.state_machine.current_state is IdleState:
		_player.state_machine.transition("AttackState")
	if _correct_count >= CORRECT_ANSWERS_TO_KILL:
		_enemy.hp = 0
		_battle_over = true
		_battle_won = true
	else:
		_enemy.hp = max(1, _enemy.hp - _damage_per_correct)
	if is_instance_valid(_enemy.health_bar):
		_enemy.health_bar.update_bar(float(_enemy.hp) / float(_enemy.max_hp))
	_flash_sprite(_enemy.sprite, Color(1, 0.4, 0.4))

func _apply_wrong_answer():
	var damage: float = max(1.0, float(_enemy.current_damage))
	if _player.Stats.current_hp - damage <= 0:
		_player.Stats.current_hp = 1  # finalized to 0 on result-screen continue
		_battle_over = true
		_battle_won = false
	else:
		_player.Stats.current_hp -= ceil(damage)
	_player.launch_label("%d" % ceil(damage))
	_flash_sprite(_player.sprite, Color(1, 0.4, 0.4))
	if is_instance_valid(_enemy):
		var anim : AnimationPlayer = _enemy.get_node_or_null("AnimationPlayer")
		if anim and anim.has_animation("Attack"):
			anim.play("Attack", -1, 1.5)

func _flash_sprite(sprite: Node, flash_color: Color):
	if not is_instance_valid(sprite):
		return
	var tw := create_tween()
	tw.tween_property(sprite, "modulate", flash_color, 0.08)
	tw.tween_property(sprite, "modulate", Color.WHITE, 0.15)

func _on_continue_pressed():
	if _awaiting_result_dismiss:
		_awaiting_result_dismiss = false
		_finish_battle()
		return
	if not _awaiting_continue:
		return
	_awaiting_continue = false
	if _battle_over:
		_show_result_screen(_battle_won)
		return
	_ask_next_question()

func _show_result_screen(won: bool):
	_awaiting_result_dismiss = true
	_ui.show_battle_result(won, _question_count)

func _finish_battle():
	_battle_active = false
	_ui.visible = false
	if _player.died.is_connected(_on_player_died_external):
		_player.died.disconnect(_on_player_died_external)
	_freeze_enemy(false)

	if _battle_won:
		_enemy.hp = 0
		_enemy.state_machine.transition("DieState")
		# Hold camera + freeze player so the student sees the death animation
		# clearly before control returns.
		await get_tree().create_timer(ENEMY_DEATH_DELAY).timeout
		_zoom_camera_out()
		_player.frozen = false
	else:
		_enemy.in_battle = false
		_zoom_camera_out()
		_player.frozen = false
		# Drop player HP to 0 to trigger the normal death pipeline through Stats.
		_player.Stats.current_hp = 0
		await get_tree().create_timer(0.5).timeout
		_player.died.emit(true)

	battle_ended.emit(_battle_won, _correct_count, _question_count)
