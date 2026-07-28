extends Control
## Settings screen: read-only key-bind reference (keyboard + controller columns)
## plus the language toggle. Used as a swapped menu from the main menu and as an
## overlay instanced inside the pause menu's CanvasLayer.

signal back_pressed

const C_BG      := Color(0.03, 0.05, 0.10)
const C_CARD_BG := Color(0.09, 0.14, 0.28)
const C_EDGE    := Color(0.12, 0.55, 0.82, 0.50)
const C_CYAN    := Color(0.14, 0.85, 1.00)
const C_WHITE   := Color(1.00, 1.00, 1.00)
const C_BLACK   := Color(0.00, 0.00, 0.00)
const C_MUTED   := Color(0.45, 0.60, 0.72)
const C_VALUE   := Color(0.80, 0.90, 1.00)
const C_BACK    := Color(0.35, 0.35, 0.38)

# label is wrapped in tr() at build time; action "" rows are special-cased
const BIND_ROWS := [
	{"label": "Move",          "action": ""},
	{"label": "Jump",          "action": "Jump"},
	{"label": "Crouch",        "action": "ui_down"},
	{"label": "Attack",        "action": "Attack"},
	{"label": "Dash",          "action": "Dash"},
	{"label": "Slide",         "action": "Slide"},
	{"label": "Interact",      "action": "interact"},
	{"label": "Pause",         "action": "pause"},
	{"label": "Menu Select",   "action": "ui_accept"},
	{"label": "Menu Back",     "action": "ui_cancel"},
]

var _back_btn : Button
var _lang_btn : Button

func _ready():
	var vp := get_viewport_rect().size
	size = vp
	position = Vector2.ZERO
	_build_ui(vp)

func _build_ui(vp: Vector2) -> void:
	var bg := ColorRect.new()
	bg.color = C_BG
	bg.size = vp
	add_child(bg)

	for y in [0.0, vp.y - 1.0]:
		var edge := ColorRect.new()
		edge.color = C_EDGE
		edge.size = Vector2(vp.x, 1)
		edge.position = Vector2(0, y)
		add_child(edge)

	# Header band
	var band := ColorRect.new()
	band.color = Color(0.04, 0.08, 0.16, 0.80)
	band.size = Vector2(vp.x, 44)
	add_child(band)
	var sep := ColorRect.new()
	sep.color = C_EDGE
	sep.size = Vector2(vp.x, 1)
	sep.position = Vector2(0, 44)
	add_child(sep)

	var title_sh := _lbl(tr("SETTINGS"), 22, Color(0, 0, 0, 0.8))
	title_sh.size.x = vp.x
	title_sh.position = Vector2(2, 12)
	add_child(title_sh)
	var title := _lbl(tr("SETTINGS"), 22, C_WHITE)
	title.add_theme_color_override("font_outline_color", C_BLACK)
	title.add_theme_constant_override("outline_size", 2)
	title.size.x = vp.x
	title.position = Vector2(0, 10)
	add_child(title)

	# Controls card
	var card_w := 420.0
	var card_h := 268.0
	var card := Panel.new()
	card.position = Vector2((vp.x - card_w) * 0.5, 56)
	card.size = Vector2(card_w, card_h)
	var style := StyleBoxFlat.new()
	style.bg_color = C_CARD_BG
	style.border_color = C_CYAN
	style.set_border_width_all(2)
	style.set_corner_radius_all(6)
	card.add_theme_stylebox_override("panel", style)
	add_child(card)

	var section := _lbl(tr("CONTROLS"), 14, C_CYAN)
	section.size.x = card_w
	section.position = Vector2(0, 8)
	card.add_child(section)

	var grid := GridContainer.new()
	grid.columns = 3
	grid.position = Vector2(24, 30)
	grid.size = Vector2(card_w - 48, card_h - 40)
	grid.add_theme_constant_override("h_separation", 18)
	grid.add_theme_constant_override("v_separation", 3)
	card.add_child(grid)

	for header in ["", tr("Keyboard"), tr("Controller")]:
		var hl := _grid_lbl(header, C_MUTED)
		grid.add_child(hl)

	for row in BIND_ROWS:
		grid.add_child(_grid_lbl(tr(row.label), C_WHITE))
		if row.action == "":
			grid.add_child(_grid_lbl(tr("Arrow Keys"), C_VALUE))
			grid.add_child(_grid_lbl(tr("Stick / D-Pad"), C_VALUE))
		else:
			grid.add_child(_grid_lbl(InputDeviceManager.get_binding_text(row.action, false), C_VALUE))
			grid.add_child(_grid_lbl(InputDeviceManager.get_binding_text(row.action, true), C_VALUE))

	# Language toggle
	_lang_btn = Button.new()
	_lang_btn.custom_minimum_size = Vector2(176, 24)
	_lang_btn.position = Vector2((vp.x - 176) * 0.5, vp.y - 30)
	_style_btn(_lang_btn, C_BACK)
	_pxfont(_lang_btn, 11)
	_lang_btn.pressed.connect(_on_lang_pressed)
	_refresh_lang_btn()
	add_child(_lang_btn)

	# Back button
	_back_btn = Button.new()
	_back_btn.text = tr("< Back")
	_back_btn.position = Vector2(10, vp.y - 30)
	_back_btn.custom_minimum_size = Vector2(72, 22)
	_style_btn(_back_btn, C_BACK)
	_pxfont(_back_btn, 11)
	_back_btn.pressed.connect(func(): back_pressed.emit())
	add_child(_back_btn)

	_back_btn.focus_mode = Control.FOCUS_ALL
	_lang_btn.focus_mode = Control.FOCUS_ALL
	_back_btn.focus_neighbor_right = _lang_btn.get_path()
	_back_btn.focus_neighbor_left = _lang_btn.get_path()
	_lang_btn.focus_neighbor_left = _back_btn.get_path()
	_lang_btn.focus_neighbor_right = _back_btn.get_path()
	_back_btn.grab_focus.call_deferred()

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		back_pressed.emit()

func _on_lang_pressed() -> void:
	Globals.set_language("ms" if Globals.language == "en" else "en")
	# Rebuild so every label picks up the new language
	for child in get_children():
		child.queue_free()
	_build_ui(get_viewport_rect().size)
	_lang_btn.grab_focus.call_deferred()

func _refresh_lang_btn() -> void:
	var lang_label := "English" if Globals.language == "en" else "Melayu"
	_lang_btn.text = "%s: %s" % [tr("Language"), lang_label]

# ── Helpers ───────────────────────────────────────────────────────────────────

func _lbl(text: String, fs: int, color: Color) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_color_override("font_color", color)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_pxfont(l, fs)
	return l

func _grid_lbl(text: String, color: Color) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_color_override("font_color", color)
	l.custom_minimum_size = Vector2(110, 0)
	_pxfont(l, 11)
	return l

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

func _style_btn(btn: Button, color: Color) -> void:
	var mk := func(mul: float) -> StyleBoxFlat:
		var s := StyleBoxFlat.new()
		s.bg_color = Color(color.r * mul, color.g * mul, color.b * mul)
		s.border_color = color
		s.set_border_width_all(1)
		s.set_corner_radius_all(3)
		return s
	btn.add_theme_stylebox_override("normal",  mk.call(0.22))
	btn.add_theme_stylebox_override("hover",   mk.call(0.40))
	btn.add_theme_stylebox_override("pressed", mk.call(0.12))
	btn.add_theme_stylebox_override("focus",   mk.call(0.40))
	btn.add_theme_color_override("font_color",         Color(0.92, 0.95, 1.00))
	btn.add_theme_color_override("font_hover_color",   Color(1.00, 1.00, 1.00))
	btn.add_theme_color_override("font_pressed_color", Color(0.60, 0.70, 0.80))
