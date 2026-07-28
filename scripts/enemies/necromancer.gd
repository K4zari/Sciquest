extends CharacterBody2D
class_name  Necromancer

signal died

@export var enemies : Node2D
@export var idle_anim_speed : float = 1.0

# Battle-system interface (duck-typed BasicEnemy)
@export var max_hp : int = 25
@export var current_damage : float = 4.0
@export var is_boss : bool = true
@export var die_anim_speed : float = 1.0
@export var affinity : Globals.Affinities = Globals.Affinities.NONE
@export var teleport_guarded : Area2D
@export var skeleton_scene : PackedScene

const TOTAL_SUMMONS : int = 3
const SUMMON_OFFSET : Vector2 = Vector2(-10, 0)

## Flees left, away from the player, while it still has skeletons left to summon.
const TELEPORT_TRIGGER_RANGE : float = 48.0
const TELEPORT_AWAY_DISTANCE : float = 120.0
const TELEPORT_COOLDOWN : float = 1.2

var _teleport_cooldown : float = 0.0

@onready var state_machine : FiniteStateMachine = $FiniteStateMachine
@onready var sprite : Sprite2D = $Marker2D/Sprite2D
@onready var pivot : Marker2D = $Marker2D
@onready var animation_player : AnimationPlayer = $AnimationPlayer

var health_bar = null
var hp : int
var is_dead : bool = false
var in_battle : bool = false

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var potential_targets : Array = []

## Set once every summoned skeleton is defeated and the barrier is gone — the
## next hit from the player kills the Necromancer outright (no quiz needed).
var is_vulnerable_to_final_blow : bool = false

var is_boss_fight_active : bool = false
var _boss_fight_started : bool = false
var summons_spawned : int = 0
var summons_defeated : int = 0
var _barrier : Node2D = null

const BARRIER_OFFSET : Vector2 = Vector2(0, -30)
const BarrierScript = preload("res://scripts/boss_barrier.gd")
const BOSS_BLOCK_LAYER_BIT : int = 32  # bit 5 — used to make summons solid to the player

func _ready():
	hp = max_hp
	add_to_group("Enemies")
	EventBus.enemy_spawned.emit(self)

func _process(delta: float) -> void:
	if _teleport_cooldown > 0.0:
		_teleport_cooldown -= delta
		return
	if not is_boss_fight_active or is_dead or summons_spawned >= TOTAL_SUMMONS:
		return
	if not Globals.player:
		return
	if global_position.distance_to(Globals.player.global_position) < TELEPORT_TRIGGER_RANGE:
		_teleport_away_from_player()

## Vanishes and reappears further left so the player can't melee it down before
## it finishes summoning its skeletons — keeps the quiz-driven summon fight intact.
func _teleport_away_from_player() -> void:
	_teleport_cooldown = TELEPORT_COOLDOWN
	var destination : Vector2 = global_position + Vector2(-TELEPORT_AWAY_DISTANCE, 0)
	var tw := create_tween()
	tw.tween_property(pivot, "modulate:a", 0.0, 0.12)
	tw.tween_callback(func ():
		global_position = destination
		turn_to_player()
	)
	tw.tween_property(pivot, "modulate:a", 1.0, 0.12)

func _on_revive_timer_timeout():
	if is_boss_fight_active:
		return
	if scan_for_targets():
		state_machine.transition("NecromancerCastState")

func start_boss_fight():
	if _boss_fight_started or is_dead:
		return
	_boss_fight_started = true
	is_boss_fight_active = true
	in_battle = true
	_spawn_barrier()
	_enable_player_block()
	turn_to_player()
	state_machine.transition("NecromancerCastState")

func _enable_player_block():
	if Globals.player:
		Globals.player.collision_mask |= BOSS_BLOCK_LAYER_BIT

func _disable_player_block():
	if Globals.player:
		Globals.player.collision_mask &= ~BOSS_BLOCK_LAYER_BIT

func _spawn_barrier():
	if _barrier and is_instance_valid(_barrier):
		return
	_barrier = Node2D.new()
	_barrier.set_script(BarrierScript)
	_barrier.position = BARRIER_OFFSET
	add_child(_barrier)

func _remove_barrier():
	if _barrier and is_instance_valid(_barrier):
		_barrier.queue_free()
	_barrier = null

func _on_cast_spell_apex():
	if not is_boss_fight_active or is_dead:
		return
	if summons_spawned >= TOTAL_SUMMONS:
		return
	_spawn_next_summon()

func _spawn_next_summon():
	if is_dead or skeleton_scene == null:
		push_warning("Necromancer: skeleton_scene is null; cannot spawn summon")
		return
	var summon : Skeleton = skeleton_scene.instantiate()
	summon.is_boss_summon = true
	summon.collision_layer |= BOSS_BLOCK_LAYER_BIT
	summons_spawned += 1
	summon.name = "Skeleton_Boss_%d" % summons_spawned
	var container : Node = enemies if enemies else get_parent()
	container.add_child(summon)
	summon.global_position = global_position + SUMMON_OFFSET
	summon.died.connect(_on_summon_died, CONNECT_ONE_SHOT)

func _on_summon_died(_summon):
	summons_defeated += 1
	if summons_defeated >= TOTAL_SUMMONS:
		is_boss_fight_active = false
		in_battle = false
		_remove_barrier()
		_disable_player_block()
		is_vulnerable_to_final_blow = true
		return
	if summons_spawned < TOTAL_SUMMONS:
		state_machine.transition("NecromancerCastState")

## Final hit once all summons are cleared and the barrier is down — kills the
## Necromancer outright through its normal death animation, no quiz required.
func receive_final_blow():
	if is_dead or not is_vulnerable_to_final_blow:
		return
	is_vulnerable_to_final_blow = false
	hp = 0
	state_machine.transition("DieState")

func scan_for_targets() -> bool:
	potential_targets = []
	var container := enemies if enemies else get_parent()
	if container == null:
		return false
	for target in container.get_children():
		if target is Skeleton and target.is_dead and target.is_on_screen:
			potential_targets.append(target)
	return potential_targets.size() > 0

func turn_to_player():
	if not Globals.player or not pivot:
		return
	if pivot.transform.x.dot(global_position.direction_to(Globals.player.global_position)) < 0:
		velocity.x = 0
		pivot.scale.x *= -1

func _on_died():
	died.emit(self)
