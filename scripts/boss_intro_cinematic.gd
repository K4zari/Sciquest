extends CanvasLayer
class_name BossIntroCinematic

signal cinematic_finished

@export var bar_height : float = 80.0
@export var bar_tween_time : float = 0.5
@export var camera_zoom : Vector2 = Vector2(2.5, 2.5)
@export var hold_time : float = 3.0

@onready var top_bar : ColorRect = $TopBar
@onready var bottom_bar : ColorRect = $BottomBar
@onready var boss_name_label : RichTextLabel = $BottomBar/BossNameLabel

var _camera : Camera2D
var _orig_zoom : Vector2
var _orig_offset : Vector2
var _orig_camera_y : float

func _ready():
	add_to_group("boss_cinematic")
	visible = false
	top_bar.offset_bottom = 0.0
	bottom_bar.offset_top = 0.0
	boss_name_label.modulate.a = 0.0

func play(target : Node2D, boss_name : String):
	if target == null:
		cinematic_finished.emit()
		return
	visible = true
	boss_name_label.text = (
		"[center][font_size=32]"
		+ "[color=#ff3344]◆[/color]    "
		+ "[color=white][b]%s[/b][/color]    "
		+ "[color=#ff3344]◆[/color]"
		+ "[/font_size][/center]"
	) % boss_name.to_upper()

	var player := Globals.player
	if player:
		player.frozen = true
		player.velocity = Vector2.ZERO
		if player.state_machine:
			player.state_machine.transition("IdleState")
		_camera = player.camera
	if _camera:
		_orig_zoom = _camera.zoom
		_orig_offset = _camera.offset
		_orig_camera_y = _camera.position.y

	_slide_in(target)
	await get_tree().create_timer(bar_tween_time).timeout

	if target.has_method("start_boss_fight"):
		target.start_boss_fight()

	await get_tree().create_timer(hold_time).timeout
	_slide_out()
	await get_tree().create_timer(bar_tween_time).timeout

	if player:
		player.frozen = false
	visible = false
	cinematic_finished.emit()

func _slide_in(target : Node2D):
	var tw := create_tween().set_parallel(true).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tw.tween_property(top_bar, "offset_bottom", bar_height, bar_tween_time)
	tw.tween_property(bottom_bar, "offset_top", -bar_height, bar_tween_time)
	tw.tween_property(boss_name_label, "modulate:a", 1.0, bar_tween_time * 1.4)
	if _camera and is_instance_valid(target) and Globals.player:
		var midpoint : Vector2 = target.global_position - Globals.player.global_position
		tw.tween_property(_camera, "zoom", camera_zoom, bar_tween_time)
		tw.tween_property(_camera, "offset", midpoint, bar_tween_time)
		tw.tween_property(_camera, "position:y", -10.0, bar_tween_time)

func _slide_out():
	var tw := create_tween().set_parallel(true).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	tw.tween_property(top_bar, "offset_bottom", 0.0, bar_tween_time)
	tw.tween_property(bottom_bar, "offset_top", 0.0, bar_tween_time)
	tw.tween_property(boss_name_label, "modulate:a", 0.0, bar_tween_time * 0.6)
	if _camera:
		tw.tween_property(_camera, "zoom", _orig_zoom, bar_tween_time)
		tw.tween_property(_camera, "offset", _orig_offset, bar_tween_time)
		tw.tween_property(_camera, "position:y", _orig_camera_y, bar_tween_time)
