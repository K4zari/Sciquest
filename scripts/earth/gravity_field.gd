extends Node2D
class_name GravityField

## Toggles "gravity" for the FloatingRock bodies in Zone A. Wired as a lever target:
## the level's lever calls _on_lever_activated() / _on_lever_deactivated() (see
## scripts/lever.gd). With gravity ON, rocks fall to their grounded position; with
## gravity OFF they float upward — teaching that Earth's gravity pulls objects down,
## and without it objects float.

signal gravity_changed(gravity_on : bool)

@export var gravity_on : bool = false
## Rocks to control. If left empty, every node in the "GravityBodies" group is used.
@export var rocks : Array[NodePath] = []

func _ready() -> void:
	# Apply the starting state once the whole tree (rocks included) is ready.
	call_deferred("_apply")

func _on_lever_activated() -> void:
	gravity_on = true
	_apply()

func _on_lever_deactivated() -> void:
	gravity_on = false
	_apply()

func _apply() -> void:
	for rock in _targets():
		if is_instance_valid(rock) and rock.has_method("set_gravity"):
			rock.set_gravity(gravity_on)
	gravity_changed.emit(gravity_on)

func _targets() -> Array:
	if rocks.is_empty():
		return get_tree().get_nodes_in_group("GravityBodies")
	var result : Array = []
	for np in rocks:
		var n := get_node_or_null(np)
		if n:
			result.append(n)
	return result
