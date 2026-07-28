extends Node2D
class_name InteractPrompt
## Floating "[E]" / "[B]" hint shown above the interactable the player is near.
## Tracks the active input device so the label always matches what the player
## is holding. One instance lives in each level (wired by level.gd).

const BOB_AMOUNT := 3.0

var _label : Label
var _action : String = "interact"
var _bob_tween : Tween

func _ready():
	z_index = 100
	_label = Label.new()
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0))
	_label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0))
	_label.add_theme_constant_override("outline_size", 3)
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.05, 0.08, 0.16, 0.85)
	style.border_color = Color(0.14, 0.85, 1.00)
	style.set_border_width_all(1)
	style.set_corner_radius_all(3)
	style.content_margin_left = 5
	style.content_margin_right = 5
	style.content_margin_top = 1
	style.content_margin_bottom = 1
	_label.add_theme_stylebox_override("normal", style)
	_pxfont(_label, 11)
	add_child(_label)
	InputDeviceManager.device_changed.connect(func(_c): _refresh_text())
	_refresh_text()
	hide()

func show_at(world_pos : Vector2, action : String = "interact") -> void:
	_action = action
	_refresh_text()
	global_position = world_pos
	show()
	_start_bob()

func dismiss() -> void:
	hide()
	if _bob_tween:
		_bob_tween.kill()
		_bob_tween = null

func _refresh_text() -> void:
	_label.text = "[%s]" % InputDeviceManager.get_prompt_text(_action)
	# Re-centre horizontally over the anchor point
	_label.reset_size()
	_label.position = Vector2(-_label.size.x * 0.5, -_label.size.y)

func _start_bob() -> void:
	if _bob_tween:
		_bob_tween.kill()
	var base_y := _label.position.y
	_bob_tween = create_tween().set_loops() \
		.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	_bob_tween.tween_property(_label, "position:y", base_y - BOB_AMOUNT, 0.6)
	_bob_tween.tween_property(_label, "position:y", base_y, 0.6)

func _pxfont(node: Control, size: int) -> void:
	var f := load("res://fonts/m6x11 Daniel LInssen.ttf") as FontFile
	if f == null:
		return
	f = f.duplicate() as FontFile
	f.antialiasing         = TextServer.FONT_ANTIALIASING_NONE
	f.subpixel_positioning = TextServer.SUBPIXEL_POSITIONING_DISABLED
	f.hinting              = TextServer.HINTING_NONE
	f.multichannel_signed_distance_field = false
	node.add_theme_font_override("font", f)
	node.add_theme_font_size_override("font_size", size)
