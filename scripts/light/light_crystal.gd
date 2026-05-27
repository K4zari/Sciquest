extends Area2D
class_name LightCrystal

@export var required_intensity : float = 0.4
@export var hold_duration : float = 0.1
@export var crystal_id : String = ""
@export var unlit_texture : Texture2D
@export var lit_texture : Texture2D

@onready var sprite : Node2D = $Visual if has_node("Visual") else null
@onready var _base_scale : Vector2 = sprite.scale if sprite else Vector2.ONE

var _hit_time : float = 0.0
var _was_hit_this_frame : bool = false
var lit : bool = false
var _flash_tween : Tween
var _breath_tween : Tween

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
			EventBus.crystal_unlit.emit(self)
		else:
			_hit_time = max(0.0, _hit_time - delta)
	_was_hit_this_frame = false

func on_beam_hit(intensity : float) -> void:
	if intensity >= required_intensity:
		_was_hit_this_frame = true

func _apply_lit_visual(is_lit : bool) -> void:
	_kill_tweens()
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
	if sprite:
		sprite.scale = _base_scale
	if is_lit:
		_play_lit_pulse()

func _play_lit_pulse() -> void:
	if not sprite:
		return
	_flash_tween = create_tween().set_parallel(true)
	_flash_tween.tween_property(sprite, "scale", _base_scale * 1.45, 0.12)
	_flash_tween.tween_property(sprite, "modulate", Color(1.6, 1.6, 1.3, 1.0), 0.12)
	_flash_tween.chain().set_parallel(true)
	_flash_tween.tween_property(sprite, "scale", _base_scale, 0.25)
	_flash_tween.tween_property(sprite, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.25)
	await _flash_tween.finished
	if lit:
		_start_breathing()

func _start_breathing() -> void:
	if not sprite:
		return
	_breath_tween = create_tween().set_loops()
	_breath_tween.tween_property(sprite, "scale", _base_scale * 1.06, 0.7).set_trans(Tween.TRANS_SINE)
	_breath_tween.tween_property(sprite, "scale", _base_scale, 0.7).set_trans(Tween.TRANS_SINE)

func _kill_tweens() -> void:
	if _flash_tween and _flash_tween.is_valid():
		_flash_tween.kill()
	if _breath_tween and _breath_tween.is_valid():
		_breath_tween.kill()
