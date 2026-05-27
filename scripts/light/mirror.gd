extends StaticBody2D
class_name Mirror

const ROTATION_STEP_DEG := 45.0
const ROTATION_SPEED_DEG_PER_SEC := 30.0

@export var locked : bool = false
@export var initial_angle_deg : float = 0.0

@onready var sprite : Node2D = $Visual if has_node("Visual") else null
@onready var proximity : Area2D = $Proximity if has_node("Proximity") else null
@onready var hint : Label = _find_hint_label()

var _hint_offset : Vector2 = Vector2.ZERO

signal rotated(new_angle_deg : float)
signal player_nearby(source : Node)
signal player_left

func _ready():
	add_to_group("Interactables")
	add_to_group("Mirrors")
	rotation_degrees = initial_angle_deg
	if hint:
		_hint_offset = Vector2(hint.offset_left, hint.offset_top)
		hint.top_level = true
		hint.rotation = 0.0
		_update_hint_position()
		hint.hide()
	if proximity:
		proximity.body_entered.connect(_on_body_entered)
		proximity.body_exited.connect(_on_body_exited)

func _process(_delta : float) -> void:
	if hint and hint.visible:
		_update_hint_position()

func _update_hint_position() -> void:
	hint.global_position = global_position + _hint_offset
	hint.rotation = 0.0

func _find_hint_label() -> Label:
	for child in get_children():
		if child is Label:
			return child
	return null

func _on_body_entered(_body : Node) -> void:
	if hint and not locked:
		hint.show()
	player_nearby.emit(self)

func _on_body_exited(_body : Node) -> void:
	if hint:
		hint.hide()
	player_left.emit()

func interact():
	if locked:
		return
	rotation_degrees = fposmod(rotation_degrees + ROTATION_STEP_DEG, 360.0)
	rotated.emit(rotation_degrees)

func continuous_rotate(delta : float) -> void:
	if locked:
		return
	rotation_degrees = fposmod(rotation_degrees + ROTATION_SPEED_DEG_PER_SEC * delta, 360.0)
	rotated.emit(rotation_degrees)

func reflect(incoming_dir : Vector2) -> Vector2:
	var normal := Vector2.UP.rotated(global_rotation)
	return incoming_dir.bounce(normal).normalized()

func get_surface_normal() -> Vector2:
	return Vector2.UP.rotated(global_rotation)
