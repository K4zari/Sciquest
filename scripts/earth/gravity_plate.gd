extends Area2D
class_name GravityPlate

## A pressure plate that powers a gate when a FloatingRock rests on it. Reuses the
## crystal_lit / crystal_unlit gate channel — a CrusherDoor whose linked_crystal_id
## matches this plate's crystal_id will open while a rock is resting here.

@export var crystal_id : String = ""
## When true the plate also fires for the player standing on it (used by the Gravity
## Climb so reaching the high ledge opens the gate). Remember to add the player layer
## (bit 8) to this instance's collision_mask in the scene.
@export var accept_player : bool = false

var _lit : bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

## A boulder (always) or the player (when accept_player) qualifies to press the plate.
func _qualifies(body : Node) -> bool:
	# Match by group rather than the FloatingRock type to avoid cross-script load-order
	# issues; only the boulders join "GravityBodies".
	return body.is_in_group("GravityBodies") or (accept_player and body == Globals.player)

func _on_body_entered(body : Node) -> void:
	if _qualifies(body) and not _lit:
		_lit = true
		EventBus.crystal_lit.emit(self)

func _on_body_exited(body : Node) -> void:
	if _qualifies(body) and _lit:
		_lit = false
		EventBus.crystal_unlit.emit(self)
