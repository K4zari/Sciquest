extends Area2D
class_name HurtBox

@export var target : CharacterBody2D

func _on_area_entered(area : Area2D):
	if not area.attacker:
		return

	if area.attacker is Forresta and (target is BasicEnemy or target is Necromancer):
		# Player's attack hit an enemy — spend stamina and start quiz
		var player := area.attacker as Forresta
		var enemy := target
		if enemy.is_dead or enemy.in_battle:
			return
		if player.Stats.current_stamina < BattleManager.QUIZ_STAMINA_COST:
			player.launch_label("Need stamina!")
			return
		player.Stats.current_stamina -= BattleManager.QUIZ_STAMINA_COST
		enemy.in_battle = true
		BattleManager.start_battle(enemy, Globals.current_topic)
	else:
		# Enemy or hazard attacking the player — deal direct damage,
		# unless we're in a quiz battle (the MCQ is the damage source then).
		if BattleManager.is_active() and target is Forresta:
			return
		target.take_damage(area.attacker)
		if target is Forresta and area.attacker is Skeleton \
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
