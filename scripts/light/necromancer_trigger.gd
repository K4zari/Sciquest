extends Area2D

@export var necromancer : Necromancer
@export var boss_display_name : String = "Necromancer"

var _fired : bool = false

func _on_body_entered(body : Node2D):
	if _fired or necromancer == null:
		return
	if body != Globals.player:
		return
	_fired = true
	var cinematic := _find_cinematic()
	if cinematic and cinematic.has_method("play"):
		cinematic.play(necromancer, boss_display_name)
	else:
		push_warning("NecromancerTrigger: BossIntroCinematic not found; starting fight without intro")
		necromancer.start_boss_fight()

func _find_cinematic() -> Node:
	# Sibling lookup first
	var sibling := get_parent().get_node_or_null("BossIntroCinematic") if get_parent() else null
	if sibling:
		return sibling
	# Group fallback in case node was reparented
	return get_tree().get_first_node_in_group("boss_cinematic")
