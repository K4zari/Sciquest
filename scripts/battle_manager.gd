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

# Boss fights (other than the Necromancer, whose fight is driven by its skeleton
# summons) run "one hit at a time": after a single question the quiz UI closes and
# the player must land another hit on the boss to bring it back up.
var _one_hit_mode: bool = false
var _paused_for_rehit: bool = false
var _last_answer_correct: bool = false

# When the hit that opened this battle shattered the boss's one-hit shield,
# the question still plays out but a correct answer breaks the shield instead
# of dealing real HP damage — and the heart UI is tinted cyan to show the
# boss isn't vulnerable yet.
var _shield_round: bool = false
var _camera_original_zoom: Vector2 = Vector2.ONE
var _camera_original_offset: Vector2 = Vector2.ZERO
var _camera_original_position_y: float = 0.0

const BATTLE_ZOOM := Vector2(2.2, 2.2)
const CAMERA_TWEEN_TIME := 0.4
const ENEMY_DEATH_DELAY := 1.0
const RETREAT_DISTANCE := 70.0
const RETREAT_FADE_TIME := 0.18
const RETREAT_MOVE_TIME := 0.35
const HURT_DISPLAY_TIME := 0.55

# Minimum horizontal gap to force between player and enemy when a quiz battle
# opens. The hit that starts the fight is a melee swing, so the two are often
# overlapping/clipping — nudge the enemy back so they're cleanly separated while
# the quiz UI is up.
const MIN_BATTLE_GAP := 56.0
const BATTLE_SPACING_TIME := 0.18

# Persists across all battles in a level so questions don't repeat
var _level_used: Dictionary = {}  # topic_id -> Array[int]

signal battle_ended(won: bool, correct: int, total: int)

func is_active() -> bool:
	return _battle_active

## Hard-stop the current battle and hide the quiz UI. Called when the level is torn
## down mid-fight (e.g. the player opens the pause menu and quits to the main menu) —
## the UI lives on this autoload, not the level, so it would otherwise stay on screen.
func abort_battle() -> void:
	_freeze_bystander_enemies(false)
	if is_instance_valid(_player) and _player.died.is_connected(_on_player_died_external):
		_player.died.disconnect(_on_player_died_external)
	_battle_active = false
	_paused_for_rehit = false
	_awaiting_continue = false
	_awaiting_result_dismiss = false
	_battle_over = false
	_enemy = null
	_player = null
	if _ui:
		_ui.visible = false

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

func start_battle(enemy: Node, topic_id: int, shield_round: bool = false):
	if _battle_active:
		return
	# Resuming a one-hit-at-a-time boss fight: keep its accumulated progress
	# (correct answers / damage dealt) instead of restarting the encounter.
	var resuming: bool = _paused_for_rehit and _enemy == enemy
	_paused_for_rehit = false
	_battle_active = true
	_enemy = enemy
	# A board the player was standing on the instant combat began would otherwise
	# leave its dialog box layered over the quiz UI.
	DialogManager.force_hide()
	if _enemy is BasicEnemy and _enemy.is_boss:
		AudioManager.play_music("boss")
	_player = Globals.player
	_player.frozen = true
	if not _player.died.is_connected(_on_player_died_external):
		_player.died.connect(_on_player_died_external)
	if _enemy.has_method("turn_to_player"):
		_enemy.turn_to_player()
	_freeze_enemy(true)
	_freeze_bystander_enemies(true)
	# The enemy may enter battle mid-attack/chase; the FSM is frozen but its
	# AnimationPlayer keeps the last pose. Drop it to a neutral idle so the boss
	# only animates an attack when the player actually answers wrong.
	_set_enemy_idle()
	_space_out_combatants()
	_zoom_camera_in()
	_topic_id = topic_id
	_one_hit_mode = _enemy.is_boss and not (_enemy is Necromancer)
	_shield_round = shield_round
	if not resuming:
		_question_count = 0
		_correct_count = 0
		_damage_per_correct = ceil(float(_enemy.max_hp) / float(CORRECT_ANSWERS_TO_KILL))
	_battle_over = false
	_battle_won = false
	_awaiting_continue = false
	_awaiting_result_dismiss = false
	_ui.visible = true
	_ask_next_question()

## Knock the enemy a short step back the instant the quiz opens so the two
## combatants aren't standing inside each other (the triggering hit is a melee
## swing landed at point-blank range). Reads as a small recoil and guarantees a
## clean gap for the battle framing.
func _space_out_combatants():
	if not is_instance_valid(_enemy) or not is_instance_valid(_player):
		return
	var dx: float = _enemy.global_position.x - _player.global_position.x
	if absf(dx) >= MIN_BATTLE_GAP:
		return
	var dir: float = signf(dx)
	if dir == 0.0:
		dir = -signf(_player.pivot.scale.x) if "pivot" in _player else 1.0
		if dir == 0.0:
			dir = 1.0
	var dest := Vector2(_player.global_position.x + dir * MIN_BATTLE_GAP, _enemy.global_position.y)
	var enemy_ref := _enemy
	var tw := create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tw.tween_property(enemy_ref, "global_position", dest, BATTLE_SPACING_TIME)
	tw.tween_callback(func ():
		if is_instance_valid(enemy_ref) and enemy_ref.has_method("turn_to_player"):
			enemy_ref.turn_to_player()
	)

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

func _set_enemy_idle():
	if not is_instance_valid(_enemy):
		return
	var anim: AnimationPlayer = _enemy.get_node_or_null("AnimationPlayer")
	if anim and anim.has_animation("Idle"):
		anim.play("Idle")

## Freeze/unfreeze every OTHER enemy in the level for the duration of a quiz battle,
## so a roaming enemy can't wander up and attack the player while the quiz UI is open.
## The enemy actually being fought is handled separately by _freeze_enemy().
func _freeze_bystander_enemies(freeze: bool):
	for e in get_tree().get_nodes_in_group("Enemies"):
		if e == _enemy or not is_instance_valid(e):
			continue
		var fsm = e.get_node_or_null("FiniteStateMachine")
		if fsm:
			fsm.set_process(not freeze)
			fsm.set_physics_process(not freeze)
		if "velocity" in e:
			e.velocity = Vector2.ZERO
		e.set_physics_process(not freeze)

func _on_player_died_external(_place_tomb: bool = true):
	if not _battle_active:
		return
	# Player died outside the battle flow (hazard, etc.) — force-close the UI.
	_battle_active = false
	_awaiting_continue = false
	_awaiting_result_dismiss = false
	_ui.visible = false
	_zoom_camera_out()
	_freeze_bystander_enemies(false)
	if is_instance_valid(_enemy):
		_enemy.in_battle = false
		_freeze_enemy(false)

func _ask_next_question():
	# Return the enemy to idle so any attack pose from the previous wrong answer
	# doesn't linger while the next question is on screen.
	_set_enemy_idle()
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
		QuestionBank.get_topic_name(_topic_id),
		_shield_round
	)

func _on_answer_chosen(index: int):
	if _awaiting_continue or _awaiting_result_dismiss:
		return
	var correct: bool = (index == _current_question.correct)
	_last_answer_correct = correct
	# Quiz feedback chime/buzz — distinct from the combat hit sounds so the
	# learner always hears whether their answer was right or wrong.
	AudioManager.play_sfx("answer_correct" if correct else "answer_wrong")
	if correct:
		_apply_correct_answer()
	else:
		_apply_wrong_answer()
	_ui.update_hp_bars(
		_player.Stats.current_hp,
		_player.Stats.max_hp,
		CORRECT_ANSWERS_TO_KILL - _correct_count,
		CORRECT_ANSWERS_TO_KILL,
		_shield_round
	)
	_ui.show_feedback(correct, _current_question.correct, _current_question.explanation)
	_awaiting_continue = true

func _apply_correct_answer():
	if _player.state_machine.current_state is IdleState:
		_player.state_machine.transition("AttackState")
	if _shield_round:
		# Answering correctly is what actually shatters the barrier — the hit that
		# opened this battle only bypassed it for the quiz; it doesn't touch the
		# boss's real HP or count toward the kill, and the fight continues after.
		if _enemy.has_method("break_shield"):
			_enemy.break_shield()
		_flash_sprite(_enemy.sprite, Color(0.5, 0.85, 1.0))
		_hurt_then_retreat()
		return
	_correct_count += 1
	if _correct_count >= CORRECT_ANSWERS_TO_KILL:
		_enemy.hp = 0
		_battle_over = true
		_battle_won = true
	else:
		_enemy.hp = max(1, _enemy.hp - _damage_per_correct)
	if is_instance_valid(_enemy.health_bar):
		_enemy.health_bar.update_bar(float(_enemy.hp) / float(_enemy.max_hp))
	_flash_sprite(_enemy.sprite, Color(1, 0.4, 0.4))
	# Audible feedback for landing a hit; the death sound fires later in _finish_battle,
	# synced with the death animation.
	AudioManager.play_sfx("enemy_hurt")
	if _one_hit_mode and not _battle_over:
		_hurt_then_retreat()

func _apply_wrong_answer():
	var damage: float = max(1.0, float(_enemy.current_damage))
	# Final bosses hit for a flat 6 regardless of their per-instance current_damage,
	# so every boss fight has the same stakes (player max HP is 25 → up to 4 misses).
	if "is_boss" in _enemy and _enemy.is_boss:
		damage = 6.0
	if _player.Stats.current_hp - damage <= 0:
		_player.Stats.current_hp = 1  # finalized to 0 on result-screen continue
		_battle_over = true
		_battle_won = false
	else:
		_player.Stats.current_hp -= ceil(damage)
	_player.launch_label("%d" % ceil(damage))
	_flash_sprite(_player.sprite, Color(1, 0.4, 0.4))
	AudioManager.play_sfx("player_hurt")
	if not _battle_over:
		_knockback_player_from_enemy()
	if is_instance_valid(_enemy):
		var anim : AnimationPlayer = _enemy.get_node_or_null("AnimationPlayer")
		if anim and anim.has_animation("Attack"):
			anim.play("Attack", -1, 1.5)

## Plays the enemy's Hurt animation at a readable speed, then retreats after a
## short pause so the player can see the boss react to taking damage.
func _hurt_then_retreat() -> void:
	if not is_instance_valid(_enemy):
		return
	var anim: AnimationPlayer = _enemy.get_node_or_null("AnimationPlayer")
	if anim and anim.has_animation("Hurt"):
		anim.play("Hurt", -1, 2.0)
	var enemy_ref := _enemy
	get_tree().create_timer(HURT_DISPLAY_TIME).timeout.connect(func():
		if not is_instance_valid(enemy_ref):
			return
		var a: AnimationPlayer = enemy_ref.get_node_or_null("AnimationPlayer")
		if a and a.is_playing():
			a.stop()
		if "sprite" in enemy_ref and is_instance_valid(enemy_ref.sprite):
			enemy_ref.sprite.modulate = Color.WHITE
		_retreat_enemy_from_player()
	, CONNECT_ONE_SHOT)

## One-hit bosses recoil a short hop away from the player on every hit that
## actually lands (shield-shatter or real damage) — the player has to close
## the gap again before the next strike connects, keeping the "rush forward
## and attack" rhythm the fight is meant to have. The boss physically slides
## back over a short tween so it reads as an organic step-back rather than a
## teleport, then turns to face the player again.
func _retreat_enemy_from_player():
	if not is_instance_valid(_enemy) or not is_instance_valid(_player):
		return
	var dir: float = sign(_enemy.global_position.x - _player.global_position.x)
	if dir == 0.0:
		dir = 1.0
	var destination: Vector2 = _enemy.global_position + Vector2(dir * RETREAT_DISTANCE, 0)
	if _enemy.has_method("turn_to_player"):
		_enemy.turn_to_player()
	var enemy_ref := _enemy
	var tw := create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tw.tween_property(enemy_ref, "global_position", destination, RETREAT_MOVE_TIME)
	tw.tween_callback(func ():
		if is_instance_valid(enemy_ref) and enemy_ref.has_method("turn_to_player"):
			enemy_ref.turn_to_player()
	)

## Pops the player back and away from the boss after a wrong answer — they were
## standing close enough to attack, and would otherwise be hit again the instant
## the quiz closes. Reuses the player's dormant KnockBackState for the pose/arc,
## then corrects its launch direction to point away from the boss specifically
## (KnockBackState normally launches opposite the player's facing direction).
func _knockback_player_from_enemy():
	if not is_instance_valid(_player) or not is_instance_valid(_enemy):
		return
	if not ("state_machine" in _player) or not _player.state_machine.states.has("KnockBackState"):
		return
	var away_dir: float = sign(_player.global_position.x - _enemy.global_position.x)
	if away_dir == 0.0:
		away_dir = -sign(_player.pivot.scale.x)
	_player.state_machine.transition("KnockBackState")
	_player.velocity.x = away_dir * _player.SPEED * 1.25

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
	if _one_hit_mode:
		_pause_for_rehit()
		return
	if not _last_answer_correct:
		# Getting hit by a regular enemy (slime, skeleton, etc.) knocks the player
		# out of the quiz too — they have to land another hit to resume it, same
		# as the "rush in and strike" rhythm bosses already have.
		_pause_for_rehit()
		return
	_ask_next_question()

func _show_result_screen(won: bool):
	_awaiting_result_dismiss = true
	_ui.show_battle_result(won, _question_count)

## One-hit-at-a-time bosses: close the quiz after a single question and send the
## player back out — they have to land another hit on the boss to reopen it. The
## boss's hp/progress carries over so the fight resumes where it left off.
func _pause_for_rehit():
	_battle_active = false
	_paused_for_rehit = true
	_ui.visible = false
	if _player.died.is_connected(_on_player_died_external):
		_player.died.disconnect(_on_player_died_external)
	_zoom_camera_out()
	_player.frozen = false
	_freeze_bystander_enemies(false)
	if is_instance_valid(_enemy):
		_enemy.in_battle = false
		_freeze_enemy(false)
		# The FSM was frozen mid-behaviour (chase/attack/flee/teleport) with the
		# animation forced to Idle; send it back through its original boot state so
		# it actually re-evaluates the player and resumes hunting/dodging instead of
		# standing still. Basic enemies (skeleton/slime) boot in "PatrolState" —
		# their "IdleState" is a dead-end with no exits, so a hardcoded "IdleState"
		# would freeze them permanently; bosses boot in a re-evaluating idle state.
		_resume_enemy_behaviour()

## Returns the fought enemy to the hunting/idle state it started the level in, so
## it keeps acting after a quiz pause. Falls back to "IdleState" for any enemy
## whose initial state wasn't captured.
func _resume_enemy_behaviour():
	if not ("state_machine" in _enemy) or not is_instance_valid(_enemy.state_machine):
		return
	var sm = _enemy.state_machine
	var resume_state: String = sm.initial_state_name
	if resume_state == "" or not sm.states.has(resume_state):
		resume_state = "IdleState" if sm.states.has("IdleState") else ""
	if resume_state != "":
		sm.transition(resume_state)

func _finish_battle():
	_battle_active = false
	_ui.visible = false
	if _player.died.is_connected(_on_player_died_external):
		_player.died.disconnect(_on_player_died_external)
	_freeze_enemy(false)
	_freeze_bystander_enemies(false)

	if _battle_won:
		_enemy.hp = 0
		AudioManager.play_sfx("enemy_dies")
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
