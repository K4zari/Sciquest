extends Sprite2D
class_name CloudDrift

## Gently ping-pongs the cloud layer so the sky has motion without seams. Lives in the
## sky CanvasLayer behind the world; purely cosmetic.

@export var amplitude : float = 32.0
@export var speed : float = 0.18

var _home : Vector2
var _t : float = 0.0

func _ready() -> void:
	_home = position

func _process(delta : float) -> void:
	_t += delta * speed
	position.x = _home.x + sin(_t) * amplitude
