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
	hp = max_hp
	affinity = randi() % Globals.Affinities.size()
	$AnimationPlayer.animation_finished.connect(_on_animation_finished)
	if is_boss_summon:
		call_deferred("turn_to_player")

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
	if is_boss_summon:
		if is_dead or in_battle:
			return
		if not area.attacker or not (area.attacker is Forresta):
			return
		var player := area.attacker as Forresta
		if player.Stats.current_stamina < BattleManager.QUIZ_STAMINA_COST:
			player.launch_label("Need stamina!")
			return
		player.Stats.current_stamina -= BattleManager.QUIZ_STAMINA_COST
		play_hurt_visual()
		in_battle = true
		BattleManager.start_battle(self, Globals.current_topic)
		return
	take_damage(Globals.player.Stats.current_damage, Globals.player.affinity)

func play_hurt_visual():
	$AnimationPlayer.play("Hurt", -1, 2.0)

func turn_to_player():
	if not Globals.player or not pivot:
		return
	if pivot.transform.x.dot(global_position.direction_to(Globals.player.global_position)) < 0:
		velocity.x = 0
		pivot.scale.x *= -1

func _on_died():
	died.emit(self)
	queue_free()
