extends CanvasLayer

signal resume_pressed
signal respawn_pressed
signal level_select_pressed
signal main_menu_pressed

# Set by edu_world — when false, Esc is ignored
var level_active : bool = false

var _resume_btn : Button
var _settings_overlay : Control = null

const C_CARD_BG  := Color(0.09, 0.14, 0.28)
const C_CYAN     := Color(0.14, 0.85, 1.00)
const C_WHITE    := Color(1.00, 1.00, 1.00)
const C_BLACK    := Color(0.00, 0.00, 0.00)
const C_MUTED    := Color(0.45, 0.60, 0.72)
const C_BTN_NAV  := Color(0.22, 0.38, 0.60)
const C_BTN_EXIT := Color(0.55, 0.20, 0.20)
const C_BTN_FIX  := Color(0.20, 0.52, 0.40)

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 20
	visible = false
	_build_ui()

func _build_ui() -> void:
	# Use a fixed logical size matching the project viewport (640×360)
	var vp := Vector2(640, 360)

	var overlay := ColorRect.new()
	overlay.color = Color(0.0, 0.0, 0.05, 0.72)
	overlay.size = vp
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(overlay)

	var card_w := 210.0
	var card_h := 286.0
	var card_pos := (vp - Vector2(card_w, card_h)) * 0.5

	var panel := Panel.new()
	panel.position = card_pos
	panel.size = Vector2(card_w, card_h)

	var style := StyleBoxFlat.new()
	style.bg_color = C_CARD_BG
	style.border_color = C_CYAN
	style.set_border_width_all(2)
	style.set_corner_radius_all(6)
	panel.add_theme_stylebox_override("panel", style)
	add_child(panel)

	# Top accent bar
	var top_bar := ColorRect.new()
	top_bar.color = C_CYAN
	top_bar.size = Vector2(card_w - 4, 4)
	top_bar.position = Vector2(2, 2)
	panel.add_child(top_bar)

	# Inner highlight
	var hl := ColorRect.new()
	hl.color = Color(1, 1, 1, 0.04)
	hl.size = Vector2(card_w - 4, 46)
	hl.position = Vector2(2, 6)
	panel.add_child(hl)

	# Title shadow
	var sh := _lbl("PAUSED", 33, Color(0, 0, 0, 0.65))
	sh.size.x = card_w
	sh.position = Vector2(2, 18)
	panel.add_child(sh)

	# Title
	var title := _lbl("PAUSED", 33, C_WHITE)
	title.add_theme_color_override("font_outline_color", C_BLACK)
	title.add_theme_constant_override("outline_size", 3)
	title.size.x = card_w
	title.position = Vector2(0, 16)
	panel.add_child(title)

	# Separator
	var sep := ColorRect.new()
	sep.color = Color(C_CYAN.r, C_CYAN.g, C_CYAN.b, 0.28)
	sep.size = Vector2(card_w - 24, 1)
	sep.position = Vector2(12, 62)
	panel.add_child(sep)

	var bx := 22.0
	var bw := card_w - 44.0

	_resume_btn = _make_btn("RESUME", Vector2(bx, 72), Vector2(bw, 28), C_CYAN)
	_resume_btn.pressed.connect(func(): resume_pressed.emit())
	panel.add_child(_resume_btn)

	var unstuck_btn := _make_btn("UNSTUCK", Vector2(bx, 108), Vector2(bw, 26), C_BTN_FIX)
	unstuck_btn.pressed.connect(func(): respawn_pressed.emit())
	panel.add_child(unstuck_btn)

	var lvl_btn := _make_btn("LEVEL SELECT", Vector2(bx, 142), Vector2(bw, 26), C_BTN_NAV)
	lvl_btn.pressed.connect(func(): level_select_pressed.emit())
	panel.add_child(lvl_btn)

	var binds_btn := _make_btn("KEY BINDS", Vector2(bx, 176), Vector2(bw, 26), C_BTN_NAV)
	binds_btn.pressed.connect(_open_key_binds)
	panel.add_child(binds_btn)

	var menu_btn := _make_btn("MAIN MENU", Vector2(bx, 210), Vector2(bw, 26), C_BTN_EXIT)
	menu_btn.pressed.connect(func(): main_menu_pressed.emit())
	panel.add_child(menu_btn)

	var chain : Array = [_resume_btn, unstuck_btn, lvl_btn, binds_btn, menu_btn]
	for i in chain.size():
		var btn : Button = chain[i]
		btn.focus_mode = Control.FOCUS_ALL
		btn.focus_neighbor_top = chain[(i - 1 + chain.size()) % chain.size()].get_path()
		btn.focus_neighbor_bottom = chain[(i + 1) % chain.size()].get_path()

	# ESC hint
	var hint := _lbl("[ESC / Start] to resume", 11, C_MUTED)
	hint.size.x = card_w
	hint.position = Vector2(0, card_h - 22)
	panel.add_child(hint)

# ── Public API ────────────────────────────────────────────────────────────────

func show_menu() -> void:
	visible = true
	get_tree().paused = true
	_resume_btn.grab_focus.call_deferred()

func hide_menu() -> void:
	get_tree().paused = false
	visible = false
	if _settings_overlay:
		_settings_overlay.queue_free()
		_settings_overlay = null

func _open_key_binds() -> void:
	_settings_overlay = preload("res://scripts/settings_menu.gd").new()
	_settings_overlay.back_pressed.connect(func():
		_settings_overlay.queue_free()
		_settings_overlay = null
		_resume_btn.grab_focus.call_deferred())
	add_child(_settings_overlay)

# ── Input — runs even while paused (PROCESS_MODE_ALWAYS) ─────────────────────

func _input(event: InputEvent) -> void:
	if not event.is_action_pressed("pause"):
		return
	if not level_active:
		return
	if _settings_overlay:
		# Let the settings overlay's ui_cancel handler close it instead
		return
	if visible:
		resume_pressed.emit()
	else:
		show_menu()
	get_viewport().set_input_as_handled()

# ── Helpers ───────────────────────────────────────────────────────────────────

func _lbl(text: String, fs: int, color: Color) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_color_override("font_color", color)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_pxfont(l, fs)
	return l

func _make_btn(text: String, pos: Vector2, sz: Vector2, color: Color) -> Button:
	var btn := Button.new()
	btn.text = text
	btn.position = pos
	btn.custom_minimum_size = sz
	_style_btn(btn, color)
	_pxfont(btn, 11)
	return btn

func _pxfont(node: Control, size: int) -> void:
	var f := load("res://fonts/m6x11 Daniel LInssen.ttf") as FontFile
	if f == null:
		return
	f = f.duplicate() as FontFile
	f.antialiasing            = TextServer.FONT_ANTIALIASING_NONE
	f.subpixel_positioning    = TextServer.SUBPIXEL_POSITIONING_DISABLED
	f.hinting                 = TextServer.HINTING_NONE
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
	btn.add_theme_color_override("font_color",         Color(0.92, 0.95, 1.00))
	btn.add_theme_color_override("font_hover_color",   Color(1.00, 1.00, 1.00))
	btn.add_theme_color_override("font_pressed_color", Color(0.60, 0.70, 0.80))
