extends AnimatableBody2D
class_name FloatingRock

## A boulder controlled by the zone's GravityField. With gravity ON it rests on the
## ground (its authored position); with gravity OFF it floats straight up. It is solid
## (AnimatableBody2D), so the player can stand on it and it can press a GravityPlate.

@export var float_height : float = 96.0
@export var move_time : float = 0.8

var _grounded_y : float
var _tween : Tween

func _ready() -> void:
	add_to_group("GravityBodies")
	# Authored position is the grounded (gravity-on) resting spot.
	_grounded_y = position.y

func set_gravity(on : bool) -> void:
	var target_y : float = _grounded_y if on else _grounded_y - float_height
	if _tween and _tween.is_running():
		_tween.kill()
	_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	_tween.tween_property(self, "position:y", target_y, move_time)
