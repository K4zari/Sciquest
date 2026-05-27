extends Area2D
class_name BossTrigger

@export var boss : Node2D
@export var boss_display_name : String = "BOSS"

var _fired : bool = false

func _on_body_entered(body : Node2D) -> void:
	if _fired or boss == null:
		return
	if body != Globals.player:
		return
	_fired = true
	var cinematic := _find_cinematic()
	if cinematic and cinematic.has_method("play"):
		cinematic.play(boss, boss_display_name)
	elif boss.has_method("start_boss_fight"):
		boss.start_boss_fight()

func _find_cinematic() -> Node:
	var sibling := get_parent().get_node_or_null("BossIntroCinematic") if get_parent() else null
	if sibling:
		return sibling
	return get_tree().get_first_node_in_group("boss_cinematic")
