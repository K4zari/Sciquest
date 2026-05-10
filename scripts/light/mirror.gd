extends StaticBody2D
class_name Mirror

const ROTATION_STEP_DEG := 45.0

@export var locked : bool = false
@export var initial_angle_deg : float = 0.0

@onready var sprite : Node2D = $Visual if has_node("Visual") else null

signal rotated(new_angle_deg : float)

func _ready():
	add_to_group("Interactables")
	add_to_group("Mirrors")
	rotation_degrees = initial_angle_deg

func interact():
	if locked:
		return
	rotation_degrees = fposmod(rotation_degrees + ROTATION_STEP_DEG, 360.0)
	rotated.emit(rotation_degrees)

func reflect(incoming_dir : Vector2) -> Vector2:
	var normal := Vector2.UP.rotated(global_rotation)
	return incoming_dir.bounce(normal).normalized()

func get_surface_normal() -> Vector2:
	return Vector2.UP.rotated(global_rotation)
