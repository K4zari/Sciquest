extends CharacterBody2D
class_name BasicEnemy

var label_scene = preload("res://scenes/info_label.tscn")

@onready var gap_detector : RayCast2D = $Pivot/GapDetector
@onready var wall_detector : RayCast2D = $Pivot/WallDetector
@onready var player_detector : RayCast2D = $Pivot/PlayerDetector
@onready var attack_cooldown_timer : Timer = $RestTimer
@onready var invul_timer : Timer = $InvulTimer
@onready var state_machine : FiniteStateMachine = $FiniteStateMachine
@onready var sprite : Sprite2D = $Pivot/Sprite2D
@onready var hurtbox : CollisionShape2D = $Pivot/Hurtbox/CollisionShape2D
@onready var pivot : Marker2D = $Pivot
@onready var health_bar : HealthBar = $HealthBar as HealthBar

@export var DEFAULT_STATE : String

@export_category("Statistics")
@export var SPEED : int
@export var hp : float
@export var max_hp : int
@export var current_damage : float = 1
@export var max_jump_distance : int = 5
@export var min_safe_distance : float
@export var max_overrun_distance : float
@export var affinity : Globals.Affinities = Globals.Affinities.NONE
@export var power : float = 1.0
@export var evasion_rate : float = 0.0

@export var idle_anim_speed : float = 1.0
@export var walk_anim_speed : float = 1.0
@export var run_anim_speed : float = 1.0
@export var attack_anim_speed : float = 1.0
@export var die_anim_speed : float = 1.0
@export var default_anim_speed : float = 1.0
@export var sprite_height : int
@export var facing_direction : int = 1
@export var random_facing_direction : bool = false
@export var is_boss : bool = false
@export var teleport_guarded : Area2D

var is_dead : bool = false
var is_on_screen : bool = false
var can_attack : bool = true
var in_battle : bool = false

# ── Boss shield (one-hit barrier) ────────────────────────────────────────────
# Bosses spawn behind a protective barrier that absorbs exactly one player hit;
# that hit shatters the shield (via the quiz, see BattleManager._shield_round)
# and only afterwards is the boss's HP actually vulnerable to damage.
const BarrierScript = preload("res://scripts/boss_barrier.gd")
const SHIELD_OFFSET : Vector2 = Vector2(0, -30)
var shield_active : bool = false
var _shield_barrier : Node2D = null

# ── Wind push (Topic 7 wind turbine) ─────────────────────────────────────────
var in_wind : bool = false
var wind_force : Vector2 = Vector2.ZERO
@export var wind_kill_y : float = 600.0  # fall past this Y → despawn

var gravity = Globals.gravity

signal died

func _ready():
	add_to_group("Enemies")

	self.hp = self.max_hp
	affinity = randi() % Globals.Affinities.size() as Globals.Affinities
	if not sprite_height:
		sprite_height = floor(sprite.texture.get_height() / sprite.vframes)
	if random_facing_direction:
		pivot.scale.x = pow(-1, randi() % 2)
	else:
		pivot.scale.x = facing_direction
	EventBus.enemy_spawned.emit(self)
	if is_boss:
		_acquire_shield()

## Bosses act as if shielded by a one-hit barrier/aura. Some level scenes already
## place a themed BossBarrier under the boss (e.g. level 7's fire-orange aura,
## level 9's cosmic-purple aura) — reuse that existing node so we don't layer a
## second shield on top of it. Only spawn a default one if the boss has none.
func _acquire_shield():
	for child in get_children():
		if child is Node2D and child.get_script() == BarrierScript:
			_shield_barrier = child
			shield_active = true
			return
	shield_active = true
	_shield_barrier = Node2D.new()
	_shield_barrier.set_script(BarrierScript)
	_shield_barrier.position = SHIELD_OFFSET
	_shield_barrier.fill_color = Color(0.25, 0.6, 1.0, 0.2)
	_shield_barrier.stroke_color = Color(0.4, 0.85, 1.0, 0.85)
	_shield_barrier.glow_color = Color(0.6, 0.9, 1.0, 0.55)
	add_child(_shield_barrier)

## Shatters the one-hit barrier/aura; the boss's HP becomes vulnerable from here on.
func break_shield():
	if not shield_active:
		return
	shield_active = false
	if is_instance_valid(_shield_barrier):
		var barrier := _shield_barrier
		_shield_barrier = null
		var tw := create_tween()
		tw.tween_property(barrier, "modulate:a", 0.0, 0.3)
		tw.tween_callback(barrier.queue_free)

func take_damage(enemy : Node2D):
	if  randf() < evasion_rate:
		launch_label("%s" % "Miss!")
		return
	var damage_taken : float
	if enemy is Sciquest:
		damage_taken = enemy.Stats.current_damage
	else:
		damage_taken = enemy.current_damage
	damage_taken *= Globals.affinity_interactions[affinity][enemy.affinity]

	hp -= ceil(damage_taken)
	launch_label("%d" % ceil(damage_taken))
	health_bar.update_bar(float(hp)/ max_hp)
	if hp > 0:
		AudioManager.play_sfx("enemy_hurt")
		state_machine.transition("HurtState")
	else:
		AudioManager.play_sfx("enemy_dies")
		state_machine.transition("DieState")

func drown():
	gravity = Globals.gravity * 0.1

## Called by a WindZone each physics frame while the gust overlaps this enemy.
## Hands control to WindBlownState (only enemies that have that state react).
func start_wind(force : Vector2) -> void:
	if is_dead:
		return
	wind_force = force
	if not in_wind:
		in_wind = true
		if state_machine and state_machine.states.has("WindBlownState"):
			state_machine.transition("WindBlownState")

func stop_wind() -> void:
	in_wind = false

## Blown clean off the platform into the pit below — remove from the level.
func blow_away_despawn() -> void:
	if is_dead:
		return
	is_dead = true
	queue_free()

func launch_label(text : String):
	var label = label_scene.instantiate()
	label.initialize(text)
	label.global_position = global_position + Vector2.UP * sprite_height
	get_parent().get_parent().add_child(label)

func turn_to_player():
	if pivot.transform.x.dot(global_position.direction_to(Globals.player.global_position)) < 0:
		velocity.x = 0
		pivot.scale.x *= -1

func turn_away_from_player():
	if pivot.transform.x.dot(global_position.direction_to(Globals.player.global_position)) > 0:
		velocity.x = 0
		pivot.scale.x *= -1	

func is_facing_player():
	return pivot.transform.x.dot(global_position.direction_to(Globals.player.global_position)) > 0

func is_too_close() -> bool:
	return global_position.distance_squared_to(Globals.player.global_position) < min_safe_distance * min_safe_distance

func ran_too_far() -> bool:
	return not is_facing_player() and abs(global_position.x - Globals.player.global_position.x) > max_overrun_distance

func retreated_too_far():
	return is_facing_player() and abs(global_position.x - Globals.player.global_position.x) > max_overrun_distance

func calculate_jump() -> float:
	var gap_size : int = 1
	var state = get_world_2d().direct_space_state
	var jump_possible : bool = false
	while gap_size <= max_jump_distance:
		var query = PhysicsRayQueryParameters2D.create(gap_detector.global_position + Vector2(gap_size * pivot.scale.x * Globals.TILE_SIZE, -5), gap_detector.global_position + Vector2(gap_size * pivot.scale.x * Globals.TILE_SIZE, 10), 1)
		var collision = state.intersect_ray(query)
		if collision:
			query = PhysicsRayQueryParameters2D.create(gap_detector.global_position + Vector2(0, -5), gap_detector.global_position + Vector2(gap_size * pivot.scale.x * Globals.TILE_SIZE, -5), 1)
			collision = state.intersect_ray(query)
			if not collision:
				jump_possible = true
				break
			else:
				break
		else:
			gap_size += 1
	
	if jump_possible:
		
		var jump_distance : float = gap_size * Globals.TILE_SIZE
		var jump_time : float = jump_distance / SPEED
		var jump_height : float = gravity * pow(jump_time * 0.5, 2)
		var jump_speed : float = sqrt(2 * gravity * jump_height)

		return jump_speed
		
	return -1

func _on_died():
	var tw = create_tween()
	tw.finished.connect(_on_tween_finished)
	tw.tween_property(sprite, "modulate:a", 0.0, 2.0)
	
func _on_tween_finished():
	died.emit(self)


func _on_rest_timer_timeout():
	can_attack = true


func _on_visible_on_screen_enabler_2d_screen_entered():
	pass # Replace with function body.


func _on_visible_on_screen_enabler_2d_screen_exited():
	pass # Replace with function body.


func _on_invul_timer_timeout():
	hurtbox.set_deferred("disabled", false)
