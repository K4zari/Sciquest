extends State
class_name EnemyAttackState

var attack_delay : float
var attack_started : bool

func enter_state(_prev_state : State):
	actor.velocity.x = 0
	animator.play("Idle", -1, actor.attack_anim_speed)
	attack_delay = 0.2
	attack_started = false
	
func frame_update(delta):
	if "is_boss_summon" in actor and actor.is_boss_summon and BattleManager.is_active():
		return
	if attack_started:
		return
	attack_delay -= delta
	if attack_delay <= 0:
		attack_started = true
		animator.play("Attack", -1, actor.attack_anim_speed)

func animation_finished():
	if actor.player_detector.is_colliding() or actor is FireWorm and actor.close_player_detector.is_colliding():
		transition.emit("AttackState")
	else:
		transition.emit("PatrolState")

func _on_animation_player_animation_finished(_anim_name):
	if not is_current:
		return
	animation_finished()
