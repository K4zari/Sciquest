extends State
class_name ReviveState

func enter_state(_prev_state : State):
	animator.play_backwards("Die")
	

func _on_animation_player_animation_finished(anim_name):
	if not is_current:
		return
	if anim_name == "Die" and actor.is_dead:
		actor.is_dead = false
		actor.hp = actor.max_hp if "max_hp" in actor else 2
		transition.emit(actor.DEFAULT_STATE)
