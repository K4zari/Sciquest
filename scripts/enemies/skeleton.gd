extends CharacterBody2D
class_name Skeleton

signal died

const SPEED = 16

var affinity : int

var is_dead : bool = false
var is_on_screen : bool = false
const DEFAULT_STATE : String = "PatrolState"

@export var max_hp : int = 2
@export var current_damage : float = 2.0
## A "creature of the night": stays dormant (no chasing/attacking) and is harmless until
## daylight returns, when DayNightCycle calls die_from_sun() to destroy it.
@export var sun_creature : bool = false
@export var idle_anim_speed : float = 1.0
@export var attack_anim_speed : float = 1.0
@export var die_anim_speed : float = 1.0
@export var is_boss : bool = false

var hp : int
var in_battle : bool = false
var is_boss_summon : bool = false

@onready var gap_detector = $Marker2D/GapDetector
@onready var wall_detector = $Marker2D/WallDetector
@onready var player_detector = $Marker2D/PlayerDetector
@onready var attack_cooldown_timer = $RestTimer
@onready var state_machine = $FiniteStateMachine
@onready var pivot : Marker2D = $Marker2D
@onready var sprite : Sprite2D = $Marker2D/Sprite2D
@onready var invul_timer : Timer = $RestTimer
var health_bar = null

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	add_to_group("Enemies")
	hp = max_hp
	affinity = randi() % Globals.Affinities.size()
	$AnimationPlayer.animation_finished.connect(_on_animation_finished)
	if is_boss_summon:
		call_deferred("turn_to_player")
	if sun_creature:
		call_deferred("_become_dormant")

## Freeze the FSM so the skeleton just looms in place (no patrol/chase/attack) and make
## its strike harmless — it can only be cleared by the sunrise.
func _become_dormant() -> void:
	if is_dead:
		return
	current_damage = 0.0
	velocity = Vector2.ZERO
	state_machine.set_process(false)
	state_machine.set_physics_process(false)
	var atk := $Marker2D/AttackBox/CollisionShape2D
	if atk:
		atk.set_deferred("disabled", true)
	if $AnimationPlayer.has_animation("Idle"):
		$AnimationPlayer.play("Idle")

func _on_animation_finished(_anim_name : String):
	pass

func take_damage(damage : int, attacker_affinity : int):
	if is_dead:
		return
	damage = int(ceil(damage * Globals.affinity_interactions[affinity][attacker_affinity]))
	hp -= damage
	if hp > 0:
		state_machine.transition("HurtState")
	else:
		state_machine.transition("DieState")


func _on_visible_on_screen_enabler_2d_screen_exited():
	is_on_screen = false
	if not is_dead:
		state_machine.transition("IdleState")


func _on_visible_on_screen_enabler_2d_screen_entered():
	is_on_screen = true
	if not is_dead:
		state_machine.transition("PatrolState")


func _on_hurtbox_area_entered(area : Area2D):
	# Standalone skeletons and necromancer summons both fight through the MCQ
	# battle: the player swings, a question is asked, and correct answers damage
	# the skeleton (BattleManager calls take_damage).
	if is_dead or in_battle:
		return
	# A quiz is already on screen — e.g. this same swing also clipped another
	# skeleton that grabbed the battle first. Bail before latching in_battle or
	# spending stamina, otherwise start_battle() bails on _battle_active and this
	# skeleton is left with in_battle stuck true and becomes permanently un-hittable
	# (the BattleManager only ever clears in_battle on the enemy it is fighting).
	if BattleManager.is_active():
		return
	if not area.attacker or not (area.attacker is Sciquest):
		return
	var player := area.attacker as Sciquest
	if player.Stats.current_stamina < BattleManager.QUIZ_STAMINA_COST:
		player.launch_label("Need stamina!")
		return
	player.Stats.current_stamina -= BattleManager.QUIZ_STAMINA_COST
	play_hurt_visual()
	in_battle = true
	BattleManager.start_battle(self, Globals.current_topic)

func play_hurt_visual():
	$AnimationPlayer.play("Hurt", -1, 2.0)

func turn_to_player():
	if not Globals.player or not pivot:
		return
	if pivot.transform.x.dot(global_position.direction_to(Globals.player.global_position)) < 0:
		velocity.x = 0
		pivot.scale.x *= -1

## Destroyed by sunlight when day returns (driven by DayNightCycle). The skeleton is
## a night creature, so the rising sun crumbles it.
func die_from_sun() -> void:
	if is_dead or in_battle:
		return
	# Re-enable the FSM (dormant skeletons freeze it) so the death animation plays out.
	state_machine.set_process(true)
	state_machine.set_physics_process(true)
	var tw := create_tween()
	tw.tween_property(sprite, "modulate", Color(2.0, 1.9, 1.4, 1.0), 0.25)
	state_machine.transition("DieState")

func _on_died():
	died.emit(self)
	queue_free()
