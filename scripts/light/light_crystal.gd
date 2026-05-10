extends Area2D
class_name LightCrystal

@export var required_intensity : float = 0.4
@export var hold_duration : float = 0.1
@export var crystal_id : String = ""
@export var unlit_texture : Texture2D
@export var lit_texture : Texture2D

@onready var sprite : Node2D = $Visual if has_node("Visual") else null

var _hit_time : float = 0.0
var _was_hit_this_frame : bool = false
var lit : bool = false

signal crystal_lit_signal
signal crystal_unlit

func _ready():
	add_to_group("LightCrystals")
	_apply_lit_visual(false)

func _physics_process(delta : float):
	if _was_hit_this_frame:
		_hit_time += delta
		if not lit and _hit_time >= hold_duration:
			lit = true
			_apply_lit_visual(true)
			crystal_lit_signal.emit()
			EventBus.crystal_lit.emit(self)
	else:
		if lit:
			lit = false
			_hit_time = 0.0
			_apply_lit_visual(false)
			crystal_unlit.emit()
		else:
			_hit_time = max(0.0, _hit_time - delta)
	_was_hit_this_frame = false

func on_beam_hit(intensity : float) -> void:
	if intensity >= required_intensity:
		_was_hit_this_frame = true

func _apply_lit_visual(is_lit : bool) -> void:
	if sprite is Sprite2D and (lit_texture or unlit_texture):
		var sp := sprite as Sprite2D
		if is_lit and lit_texture:
			sp.texture = lit_texture
			sp.modulate = Color(1.0, 1.0, 1.0, 1.0)
		elif not is_lit and unlit_texture:
			sp.texture = unlit_texture
			sp.modulate = Color(0.7, 0.7, 0.8, 1.0)
	elif sprite and sprite is CanvasItem:
		(sprite as CanvasItem).modulate = Color(1.6, 1.6, 0.8) if is_lit else Color(0.5, 0.5, 0.6)
