extends Area2D
class_name PressurePlate

## A floor plate that "lights" its linked crystal_id while the player stands on it.
## A CrusherDoor with a matching linked_crystal_id then opens. This is the generic
## "you solved it" trigger placed at the goal of each machine chamber, so the puzzle
## scripts (see_saw, ramp, pulley platform) stay decoupled from the doors they open.

@export var crystal_id : String = ""
## When true the plate stays lit after the first activation (most puzzles); when
## false it lights only while a body rests on it (auto-relocking doors).
@export var latching : bool = true

var _lit : bool = false

@onready var _sprite : Sprite2D = get_node_or_null("Sprite2D")

func _on_body_entered(_body : Node2D) -> void:
	if _lit:
		return
	_lit = true
	_press(true)
	EventBus.crystal_lit.emit(self)

func _on_body_exited(_body : Node2D) -> void:
	if latching:
		return
	_lit = false
	_press(false)
	EventBus.crystal_unlit.emit(self)

func _press(down : bool) -> void:
	if _sprite:
		# nudge the plate sprite down a couple px when pressed for tactile feedback
		_sprite.region_rect.position.x = 16 if down else 0
