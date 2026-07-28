extends Area2D

var pickable_scene = preload("res://scenes/pickable.tscn")
var fuel_orb_scene = preload("res://scenes/fuel_orb.tscn")

@onready var sprite = $Sprite2D

@export_enum("Wooden", "Black", "Red", "White") var type = 0
@export var requires_key : bool = false
@export var key_required : Globals.Pickups = Globals.Pickups.KEY_GOLD

@export var content : Globals.Pickups = Globals.Pickups.POTION_HEALTH

## When true, opening the chest spawns a grabbable energy orb (Topic 7) instead
## of a Pickable. The orb hovers above the chest and is collected with E.
@export var contains_energy : bool = false
@export var energy_source : FuelOrb.Source = FuelOrb.Source.SOLAR



signal player_nearby(chest : Area2D)
signal player_left

const types : Array = ["Wooden", "Black", "Red", "White"]
	
func _ready():
	add_to_group("Interactables")
	#if not content:
	#	content = randi() % Globals.Pickups.size() as Globals.Pickups
	if requires_key and key_required < Globals.Pickups.KEY_GOLD:
		key_required = Globals.Pickups.KEY_GOLD
	sprite.frame = type * 10

func interact():
	var anim_name = "Open" + types[type]
	$AnimationPlayer.play(anim_name)
	AudioManager.play_sfx("chest_open")

func _on_body_entered(_body):
	player_nearby.emit(self)

func _on_body_exited(_body):
	player_left.emit()


func _on_animation_player_animation_finished(_anim_name):
	if contains_energy:
		var orb = fuel_orb_scene.instantiate()
		orb.source = energy_source
		orb.position = Vector2(0, -24)
		call_deferred("add_child", orb)
		$CollisionShape2D.set_deferred("disabled", true)
		player_left.emit()
		return
	var pickable = pickable_scene.instantiate()
	pickable.in_chest = true
	pickable.type = content
	pickable.position = Vector2(0, -8)
	if global_position.x > Globals.player.global_position.x:
		pickable.pop_direction = 1
	else:
		pickable.pop_direction = -1
	call_deferred("add_child", pickable)
	$CollisionShape2D.set_deferred("disabled", true)
	player_left.emit()
