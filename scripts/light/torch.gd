extends Node2D
class_name Torch

@export var emit_on_start : bool = true
@export var aim_angle_deg : float = 0.0
@export var rotatable : bool = false
@export var rotation_step_deg : float = 15.0
@export var togglable : bool = false

@onready var beam : Node = $LightBeam if has_node("LightBeam") else null
@onready var sprite : Node = $Sprite if has_node("Sprite") else null
@onready var proximity : Area2D = $Proximity if has_node("Proximity") else null
@onready var hint : Label = _find_hint_label()

signal player_nearby(source : Node)
signal player_left

func _ready():
	add_to_group("Torches")
	if rotatable or togglable:
		add_to_group("Interactables")
	rotation_degrees = aim_angle_deg
	if beam:
		beam.enabled = emit_on_start
	_apply_lit_visual(emit_on_start)
	if hint:
		hint.hide()
	if proximity:
		proximity.body_entered.connect(_on_body_entered)
		proximity.body_exited.connect(_on_body_exited)

func _find_hint_label() -> Label:
	for child in get_children():
		if child is Label:
			return child
	return null

func interact():
	if rotatable:
		rotation_degrees = fposmod(rotation_degrees + rotation_step_deg, 360.0)
		return
	if togglable:
		set_emitting(not (beam and beam.enabled))

func set_emitting(on : bool) -> void:
	if beam:
		beam.enabled = on
	_apply_lit_visual(on)

func _apply_lit_visual(lit : bool) -> void:
	if sprite is CanvasItem:
		(sprite as CanvasItem).modulate = Color(1.0, 1.0, 1.0, 1.0) if lit else Color(0.75, 0.75, 0.85, 1.0)

func _on_body_entered(_body : Node) -> void:
	if hint and (rotatable or togglable):
		hint.show()
	player_nearby.emit(self)

func _on_body_exited(_body : Node) -> void:
	if hint:
		hint.hide()
	player_left.emit()
