extends Node2D

# The damage system reads `current_damage` and `affinity` off whatever is set as
# an AttackBox's `attacker` (see stats.gd / basic_enemy_template.gd), so the spell
# must expose those names — the spell node is its own attacker.
var current_damage : float = 3.0
var affinity : int = Globals.Affinities.NONE

func _ready():
	$AnimationPlayer.play("Spell", -1, 0.75)

func _on_animation_player_animation_finished(_anim_name):
	queue_free()
