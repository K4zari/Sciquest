extends Area2D
class_name BossTrigger

@export var boss : Node2D
@export var boss_display_name : String = "BOSS"

var _fired : bool = false
var _armed : bool = false

func _ready() -> void:
	# Connect in code (guarded) so we don't depend on the scene wiring and don't
	# double-connect the editor-made body_entered signal.
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)

func _physics_process(_delta : float) -> void:
	# Once the player has crossed into the boss gate we wait until they're actually
	# standing on the arena floor before starting the cinematic. Firing while they
	# are still mid-jump froze them in the air and they fell off the map. We latch
	# on entry (rather than requiring them to stay inside the zone) because the jump
	# arc can carry them out the far side of the trigger before they touch down.
	if _fired or not _armed or boss == null:
		return
	var player := Globals.player
	if player == null or not is_instance_valid(player):
		return
	if player.is_on_floor():
		_fire()

func _on_body_entered(body : Node2D) -> void:
	if _fired or boss == null:
		return
	if body != Globals.player:
		return
	_armed = true

func _fire() -> void:
	_fired = true
	_armed = false
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
