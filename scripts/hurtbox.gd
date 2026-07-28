extends Area2D
class_name HurtBox

@export var target : CharacterBody2D

func _on_area_entered(area : Area2D):
	if not area.attacker:
		return

	if area.attacker is Sciquest and (target is BasicEnemy or target is Necromancer):
		# Player's attack hit an enemy — spend stamina and start quiz
		var player := area.attacker as Sciquest
		var enemy := target
		# If a quiz is already running (e.g. the same swing clipped two enemies),
		# ignore this one. Otherwise we'd latch in_battle on an enemy the
		# BattleManager isn't tracking — start_battle() bails on _battle_active —
		# and it would become permanently un-hittable.
		if enemy.is_dead or enemy.in_battle or BattleManager.is_active():
			return
		# Necromancer: once its summons are all cleared and its barrier is gone,
		# the next hit kills it outright through its death animation — no quiz.
		if enemy is Necromancer and enemy.is_vulnerable_to_final_blow:
			enemy.receive_final_blow()
			return
		if player.Stats.current_stamina < BattleManager.QUIZ_STAMINA_COST:
			player.launch_label("Need stamina!")
			return
		player.Stats.current_stamina -= BattleManager.QUIZ_STAMINA_COST
		# Bosses spawn behind a one-hit barrier; landing the first hit just opens
		# a "shield round" quiz (hearts tinted cyan) — the barrier itself only
		# shatters once the player actually answers correctly (see
		# BattleManager._shield_round / _apply_correct_answer).
		var was_shielded : bool = "shield_active" in enemy and enemy.shield_active
		enemy.in_battle = true
		BattleManager.start_battle(enemy, Globals.current_topic, was_shielded)
	else:
		# Enemy or hazard attacking the player — deal direct damage,
		# unless we're in a quiz battle (the MCQ is the damage source then).
		if BattleManager.is_active() and target is Sciquest:
			return
		target.take_damage(area.attacker)
		if target is Sciquest and area.attacker is Skeleton \
				and area.attacker.is_boss_summon \
				and not area.attacker.in_battle \
				and not area.attacker.is_dead \
				and not BattleManager.is_active():
			area.attacker.in_battle = true
			BattleManager.start_battle(area.attacker, Globals.current_topic)

func deactivate():
	$CollisionShape2D.set_deferred("disabled", true)

func activate():
	$CollisionShape2D.set_deferred("disabled", false)
