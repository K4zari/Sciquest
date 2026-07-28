extends AnimatableBody2D
class_name Ramp

## Inclined plane (KSSR 10.2.1).
##
## A wedge whose hypotenuse is a gentle, walkable slope from the floor up to the
## top of a wall too tall to jump. It starts hidden above the screen and, when its
## Lever is pulled (targets = [this]), crashes down from the sky and lands flush —
## its left edge on the floor and its right edge against the wall — so the player
## can walk up it. Teaches that a ramp reaches a high place with less effort over a
## longer, gentler path than climbing straight up.

## How far above its rest position the slab starts before falling.
@export var fall_height : float = 400.0
@export var fall_duration : float = 0.35
## How far past rest it overshoots on impact before bouncing back.
@export var impact_overshoot : float = 14.0
@export var settle_duration : float = 0.18

@onready var _col : CollisionPolygon2D = $CollisionPolygon2D

var _rest_y : float
var _deployed : bool = false
var _tween : Tween

func _ready() -> void:
	_rest_y = position.y
	_set_active(false)
	position.y = _rest_y - fall_height
	modulate.a = 0.0

func _on_lever_activated() -> void:
	if _deployed:
		return
	_deployed = true
	modulate.a = 1.0
	position.y = _rest_y - fall_height
	if _tween and _tween.is_running():
		_tween.kill()
	_tween = create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	_tween.tween_property(self, "position:y", _rest_y + impact_overshoot, fall_duration) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	_tween.tween_callback(_on_impact)
	_tween.tween_property(self, "position:y", _rest_y, settle_duration) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func _on_impact() -> void:
	_set_active(true)
	AudioManager.play_sfx("crusher")

func _on_lever_deactivated() -> void:
	if not _deployed:
		return
	_deployed = false
	if _tween and _tween.is_running():
		_tween.kill()
	position.y = _rest_y - fall_height
	modulate.a = 0.0
	_set_active(false)

func _set_active(on : bool) -> void:
	_col.set_deferred("disabled", not on)
