extends State
class_name BasicPatrolState

func enter_state(_prev_state : State):
	actor.velocity.x = pivot.scale.x * actor.SPEED
	animator.play("Walk")

func physics_update(delta):
	if not actor.is_on_floor():
		actor.velocity.y += actor.gravity * delta

	if "is_boss_summon" in actor and actor.is_boss_summon:
		if BattleManager.is_active():
			actor.velocity.x = 0
			actor.move_and_slide()
			return
		actor.turn_to_player()
		if actor.player_detector.is_colliding():
			transition.emit("AttackState")
		actor.velocity.x = pivot.scale.x * actor.SPEED * 5.0
		actor.move_and_slide()
		return

	if not actor.gap_detector.is_colliding() or actor.wall_detector.is_colliding():
		pivot.scale.x *= -1

	if actor.player_detector.is_colliding():
		transition.emit("AttackState")

	actor.velocity.x = pivot.scale.x * actor.SPEED

	actor.move_and_slide()
