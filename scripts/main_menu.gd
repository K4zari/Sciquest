extends Control

signal play_pressed
signal settings_pressed

var _glow_lbl   : Label
var _shadow_lbl : Label
var _title_lbl  : Label
var _subtitle   : Label
var _sep_line_l : ColorRect
var _sep_line_r : ColorRect
var _sep_gem    : Label
var _gems       : Array = []
var _play_btn     : Button
var _settings_btn : Button
var _quit_btn     : Button
var _lang_btn     : Button
var _topics_lbl : Label
var _parallax   : ParallaxBackground
var _veil       : ColorRect

# Forest parallax layer set (shared with level_4_plants.tscn), ordered
# back (sky) → front (foreground). Reused as a drifting menu backdrop.
const PARALLAX_LAYERS := [
	"res://graphics/environment/background/Layer_0011_0.png",
	"res://graphics/environment/background/Layer_0010_1.png",
	"res://graphics/environment/background/Layer_0009_2.png",
	"res://graphics/environment/background/Layer_0008_3.png",
	"res://graphics/environment/background/Layer_0007_Lights.png",
	"res://graphics/environment/background/Layer_0006_4.png",
	"res://graphics/environment/background/Layer_0005_5.png",
	"res://graphics/environment/background/Layer_0004_Lights.png",
	"res://graphics/environment/background/Layer_0003_6.png",
	"res://graphics/environment/background/Layer_0002_7.png",
	"res://graphics/environment/background/Layer_0001_8.png",
	"res://graphics/environment/background/Layer_0000_9.png",
]
const PARALLAX_TEX_W := 928.0   # source layer width (for seamless mirroring)
const PARALLAX_TEX_H := 739.0   # source layer height
const PARALLAX_DRIFT := 8.0     # px/sec base scroll speed

# ── Palette ───────────────────────────────────────────────────────────────────
const C_TITLE   := Color(1.00, 1.00, 1.00)        # white pixel title
const C_OUTLINE := Color(0.00, 0.00, 0.00)        # black pixel border
const C_SHADOW  := Color(0.00, 0.00, 0.00, 0.85)  # black drop shadow
const C_GLOW    := Color(0.10, 0.70, 1.00, 0.07)  # subtle cyan glow behind
const C_GEM     := Color(0.20, 0.78, 0.95)        # slightly deeper cyan
const C_ACCENT  := Color(0.12, 0.55, 0.82, 0.50)  # separator / edge lines
const C_SUB     := Color(0.48, 0.68, 0.78)        # muted blue-grey subtitle
const C_STAR    := Color(0.35, 0.85, 1.00)        # sparkle stars
const C_BTN_PRI := Color(0.08, 0.58, 0.90)        # Start Learning button
const C_BTN_SEC := Color(0.36, 0.36, 0.36)        # Quit button
const C_BG      := Color(0.03, 0.05, 0.10)        # dark-navy background

func _ready():
	AudioManager.play_music("main_menu")
	var vp := get_viewport_rect().size
	size = vp
	position = Vector2.ZERO
	_build_ui(vp)
	_run_entrance(vp)

# ── Build ─────────────────────────────────────────────────────────────────────

func _build_ui(vp: Vector2) -> void:
	# Drifting forest parallax behind everything (own CanvasLayer at layer -1)
	_build_parallax(vp)

	# Dim navy veil over the parallax so title/buttons stay readable
	_veil = _make_rect(Color(C_BG.r, C_BG.g, C_BG.b, 0.55), vp, Vector2.ZERO)
	add_child(_veil)

	# Faint blue centre glow
	for i in 3:
		var gr := ColorRect.new()
		var s := Vector2(420 - i * 80, 200 - i * 40)
		gr.size = s
		gr.position = (vp - s) * 0.5 + Vector2(0, -20)
		gr.color = Color(0.05, 0.25, 0.50, 0.05 - i * 0.01)
		add_child(gr)

	# Thin cyan top and bottom edge lines
	for y in [0.0, vp.y - 1.0]:
		var edge := ColorRect.new()
		edge.color = C_ACCENT
		edge.size = Vector2(vp.x, 1)
		edge.position = Vector2(0, y)
		add_child(edge)

	# Sparkle stars — invisible until their flicker tween fires
	var star_pos := [
		Vector2(0.15, 0.18), Vector2(0.82, 0.12), Vector2(0.08, 0.55),
		Vector2(0.90, 0.50), Vector2(0.22, 0.80), Vector2(0.75, 0.78),
		Vector2(0.50, 0.88), Vector2(0.48, 0.10),
	]
	for sp in star_pos:
		var star := Label.new()
		star.text = "✦"
		star.add_theme_font_size_override("font_size", 9)
		star.add_theme_color_override("font_color", C_STAR)
		star.modulate.a = 0.0
		star.position = vp * sp
		add_child(star)
		_animate_sparkle(star)

	# ── Title block ──────────────────────────────────────────────────────────
	var title_cy := vp.y * 0.28
	var title_fs := 44   # 4× the m6x11 native 11 px — sharpest pixel rendering

	_glow_lbl = _make_lbl(tr("SciQuest"), title_fs + 4,
		C_GLOW, vp.x, Vector2(0, title_cy - 3))
	_apply_pixel_font(_glow_lbl, title_fs + 4)
	_glow_lbl.modulate.a = 0.0
	add_child(_glow_lbl)

	_shadow_lbl = _make_lbl(tr("SciQuest"), title_fs,
		C_SHADOW, vp.x, Vector2(4, title_cy + 4))
	_apply_pixel_font(_shadow_lbl, title_fs)
	_shadow_lbl.modulate.a = 0.0
	add_child(_shadow_lbl)

	_title_lbl = _make_lbl(tr("SciQuest"), title_fs,
		C_TITLE, vp.x, Vector2(0, title_cy + 8))
	_apply_pixel_font(_title_lbl, title_fs)
	_title_lbl.add_theme_color_override("font_outline_color", C_OUTLINE)
	_title_lbl.add_theme_constant_override("outline_size", 3)
	_title_lbl.modulate.a = 0.0
	add_child(_title_lbl)

	for side in [-1, 1]:
		var gem := Label.new()
		gem.text = "◆"
		gem.add_theme_font_size_override("font_size", 11)
		gem.add_theme_color_override("font_color", C_GEM)
		gem.modulate.a = 0.0
		gem.position = Vector2(vp.x * 0.5 + side * 108, title_cy + 14)
		add_child(gem)
		_gems.append(gem)

	_subtitle = _make_lbl(tr("Year 4 Science Adventure"), 10,
		C_SUB, vp.x, Vector2(0, title_cy + 50))
	_subtitle.modulate.a = 0.0
	add_child(_subtitle)

	var sep_y  := title_cy + 72.0
	var sep_cx := vp.x * 0.5
	var sep_w  := 100.0
	_sep_line_l = _make_rect(C_ACCENT,
		Vector2(sep_w, 1), Vector2(sep_cx - sep_w - 8, sep_y))
	_sep_line_l.modulate.a = 0.0
	add_child(_sep_line_l)
	_sep_line_r = _make_rect(C_ACCENT,
		Vector2(sep_w, 1), Vector2(sep_cx + 8, sep_y))
	_sep_line_r.modulate.a = 0.0
	add_child(_sep_line_r)
	_sep_gem = Label.new()
	_sep_gem.text = "◆"
	_sep_gem.add_theme_font_size_override("font_size", 9)
	_sep_gem.add_theme_color_override("font_color", C_GEM)
	_sep_gem.modulate.a = 0.0
	_sep_gem.position = Vector2(sep_cx - 5, sep_y - 5)
	add_child(_sep_gem)

	# ── Buttons (start offset below final position) ──────────────────────────
	var btn_cx := vp.x * 0.5
	var btn_y  := vp.y * 0.56

	_play_btn = Button.new()
	_play_btn.text = tr("Start Learning")
	_play_btn.custom_minimum_size = Vector2(212, 44)
	_play_btn.position = Vector2(btn_cx - 106, btn_y + 20)
	_play_btn.modulate.a = 0.0
	_style_btn(_play_btn, C_BTN_PRI, 22)
	_play_btn.pressed.connect(func(): play_pressed.emit())
	add_child(_play_btn)

	_settings_btn = Button.new()
	_settings_btn.text = tr("Settings")
	_settings_btn.custom_minimum_size = Vector2(150, 26)
	_settings_btn.position = Vector2(btn_cx - 75, btn_y + 66)
	_settings_btn.modulate.a = 0.0
	_style_btn(_settings_btn, C_BTN_SEC, 16)
	_settings_btn.pressed.connect(func(): settings_pressed.emit())
	add_child(_settings_btn)

	_lang_btn = Button.new()
	_lang_btn.custom_minimum_size = Vector2(176, 26)
	_lang_btn.position = Vector2(btn_cx - 88, btn_y + 96)
	_lang_btn.modulate.a = 0.0
	_style_btn(_lang_btn, C_BTN_SEC, 16)
	_lang_btn.pressed.connect(_on_lang_pressed)
	_refresh_lang_btn()
	add_child(_lang_btn)

	_quit_btn = Button.new()
	_quit_btn.text = tr("Quit")
	_quit_btn.custom_minimum_size = Vector2(132, 26)
	_quit_btn.position = Vector2(btn_cx - 66, btn_y + 126)
	_quit_btn.modulate.a = 0.0
	_style_btn(_quit_btn, C_BTN_SEC, 16)
	_quit_btn.pressed.connect(func(): get_tree().quit())
	add_child(_quit_btn)

	_setup_focus()

	_topics_lbl = _make_lbl(
		tr("Plants  •  Light  •  Energy  •  Earth  •  Machines"),
		8, Color(0.28, 0.38, 0.45), vp.x, Vector2(0, vp.y - 16))
	add_child(_topics_lbl)

# ── Parallax backdrop ─────────────────────────────────────────────────────────

func _build_parallax(vp: Vector2) -> void:
	_parallax = ParallaxBackground.new()
	_parallax.layer = -1   # render behind the Control's UI
	add_child(_parallax)

	# Frame the lower portion of the tall layers against the viewport bottom.
	var y_off := vp.y - PARALLAX_TEX_H

	for i in PARALLAX_LAYERS.size():
		var tex := load(PARALLAX_LAYERS[i]) as Texture2D
		if tex == null:
			continue
		var layer := ParallaxLayer.new()
		# Far layers (sky) barely move; near layers (foreground) move most.
		var scl := 0.06 + float(i) / float(PARALLAX_LAYERS.size() - 1) * 0.74
		layer.motion_scale = Vector2(scl, 0)
		layer.motion_mirroring = Vector2(PARALLAX_TEX_W, 0)
		_parallax.add_child(layer)

		var spr := Sprite2D.new()
		spr.texture = tex
		spr.centered = false
		spr.position = Vector2(0, y_off)
		layer.add_child(spr)

func _process(delta: float) -> void:
	if _parallax:
		_parallax.scroll_offset.x -= delta * PARALLAX_DRIFT

# ── Language toggle ───────────────────────────────────────────────────────────

func _on_lang_pressed() -> void:
	Globals.set_language("ms" if Globals.language == "en" else "en")
	_refresh_all_text()

func _refresh_all_text() -> void:
	_subtitle.text      = tr("Year 4 Science Adventure")
	_play_btn.text      = tr("Start Learning")
	_settings_btn.text  = tr("Settings")
	_quit_btn.text      = tr("Quit")
	_topics_lbl.text    = tr("Plants  •  Light  •  Energy  •  Earth  •  Machines")
	_refresh_lang_btn()

func _refresh_lang_btn() -> void:
	var lang_label := "English" if Globals.language == "en" else "Melayu"
	_lang_btn.text = "%s: %s" % [tr("Language"), lang_label]

# ── Entrance sequence ─────────────────────────────────────────────────────────

func _run_entrance(vp: Vector2) -> void:
	var btn_y := vp.y * 0.60
	var t := create_tween().set_parallel(true)

	t.tween_property(_shadow_lbl, "modulate:a", 1.0, 0.30).set_delay(0.05)
	t.tween_property(_glow_lbl,   "modulate:a", 1.0, 0.40).set_delay(0.15)

	t.tween_property(_title_lbl, "modulate:a", 1.0, 0.45) \
		.set_delay(0.20).set_ease(Tween.EASE_OUT)
	t.tween_property(_title_lbl, "position:y",
		_title_lbl.position.y - 8.0, 0.50) \
		.set_delay(0.20).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

	for i in _gems.size():
		t.tween_property(_gems[i], "modulate:a", 1.0, 0.25).set_delay(0.50 + i * 0.08)

	t.tween_property(_subtitle,   "modulate:a", 1.0, 0.30).set_delay(0.60)
	t.tween_property(_sep_line_l, "modulate:a", 1.0, 0.25).set_delay(0.70)
	t.tween_property(_sep_line_r, "modulate:a", 1.0, 0.25).set_delay(0.70)
	t.tween_property(_sep_gem,    "modulate:a", 1.0, 0.25).set_delay(0.75)

	t.tween_property(_play_btn, "modulate:a",  1.0,   0.35).set_delay(0.85)
	t.tween_property(_play_btn, "position:y",  btn_y, 0.40) \
		.set_delay(0.85).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	t.tween_property(_settings_btn, "modulate:a",  1.0,        0.30).set_delay(1.00)
	t.tween_property(_settings_btn, "position:y",  btn_y + 46, 0.35) \
		.set_delay(1.00).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	t.tween_property(_lang_btn, "modulate:a",  1.0,        0.30).set_delay(1.12)
	t.tween_property(_lang_btn, "position:y",  btn_y + 76, 0.35) \
		.set_delay(1.12).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	t.tween_property(_quit_btn, "modulate:a",  1.0,         0.30).set_delay(1.24)
	t.tween_property(_quit_btn, "position:y",  btn_y + 106, 0.35) \
		.set_delay(1.24).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

	t.finished.connect(_start_idle_loops)
	t.finished.connect(func(): _play_btn.grab_focus())

# ── Idle loops ────────────────────────────────────────────────────────────────

func _start_idle_loops() -> void:
	# Glow pulse
	var gp := create_tween().set_loops() \
		.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	gp.tween_property(_glow_lbl, "modulate:a", 1.40, 2.0)
	gp.tween_property(_glow_lbl, "modulate:a", 0.55, 2.0)

	# Title shimmer — brightens toward cool blue-white, never changes hue
	var ts := create_tween().set_loops() \
		.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	ts.tween_property(_title_lbl, "self_modulate", Color(1.20, 1.15, 1.25), 2.5)
	ts.tween_property(_title_lbl, "self_modulate", Color(0.88, 0.92, 1.00), 2.5)

	# Gems bob
	for gem in _gems:
		var base_y : float = (gem as Label).position.y
		var gt := create_tween().set_loops() \
			.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
		gt.tween_property(gem, "position:y", base_y - 3.0, 1.4)
		gt.tween_property(gem, "position:y", base_y + 1.0, 1.4)

	# Sep gem slow pulse
	var sp := create_tween().set_loops() \
		.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	sp.tween_property(_sep_gem, "modulate:a", 1.0,  1.2)
	sp.tween_property(_sep_gem, "modulate:a", 0.30, 1.2)

func _animate_sparkle(star: Label) -> void:
	var delay := randf_range(0.0, 3.5)
	var dur   := randf_range(0.8, 2.2)
	var st := create_tween().set_loops()
	st.tween_interval(delay)
	st.tween_property(star, "modulate:a", randf_range(0.35, 0.80), dur * 0.4) \
		.set_ease(Tween.EASE_OUT)
	st.tween_property(star, "modulate:a", 0.0, dur * 0.6) \
		.set_ease(Tween.EASE_IN)
	st.tween_interval(randf_range(0.5, 2.5))

# ── Helpers ───────────────────────────────────────────────────────────────────

func _apply_pixel_font(node: Control, size: int) -> void:
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

func _make_lbl(text: String, fs: int, color: Color, w: float, pos: Vector2) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", fs)
	l.add_theme_color_override("font_color", color)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.size.x = w
	l.position = pos
	return l

func _make_rect(color: Color, sz: Vector2, pos: Vector2) -> ColorRect:
	var r := ColorRect.new()
	r.color = color
	r.size = sz
	r.position = pos
	return r

func _style_btn(btn: Button, color: Color, font_size: int = 16) -> void:
	# Crisp pixel font (matches the title) with a black outline for readability.
	_apply_pixel_font(btn, font_size)
	btn.add_theme_color_override("font_outline_color", C_OUTLINE)
	btn.add_theme_constant_override("outline_size", 3)

	# Sharp-cornered pixel-art plate: tinted fill + a bright top highlight border.
	var mk := func(fill_mul: float, border_mul: float) -> StyleBoxFlat:
		var s := StyleBoxFlat.new()
		s.bg_color = Color(color.r * fill_mul, color.g * fill_mul, color.b * fill_mul)
		s.border_color = Color(
			clampf(color.r * border_mul, 0.0, 1.0),
			clampf(color.g * border_mul, 0.0, 1.0),
			clampf(color.b * border_mul, 0.0, 1.0))
		s.set_border_width_all(2)
		s.border_width_bottom = 4          # chunky bottom edge reads as a pixel bevel
		s.set_corner_radius_all(2)
		s.content_margin_left   = 14
		s.content_margin_right  = 14
		s.content_margin_top    = 5
		s.content_margin_bottom = 6
		return s
	btn.add_theme_stylebox_override("normal",  mk.call(0.24, 1.05))
	btn.add_theme_stylebox_override("hover",   mk.call(0.46, 1.35))
	btn.add_theme_stylebox_override("pressed", mk.call(0.14, 0.80))
	btn.add_theme_stylebox_override("focus",   mk.call(0.46, 1.35))
	btn.add_theme_color_override("font_color",         Color(0.92, 0.97, 1.00))
	btn.add_theme_color_override("font_hover_color",   Color(1.00, 1.00, 1.00))
	btn.add_theme_color_override("font_pressed_color", Color(0.62, 0.72, 0.84))

	# Subtle grow + lift on hover/focus for tactile feedback.
	btn.pivot_offset = btn.custom_minimum_size * 0.5
	var grow := func() -> void:
		create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK) \
			.tween_property(btn, "scale", Vector2(1.06, 1.06), 0.12)
	var shrink := func() -> void:
		create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE) \
			.tween_property(btn, "scale", Vector2.ONE, 0.12)
	btn.mouse_entered.connect(grow)
	btn.mouse_exited.connect(shrink)
	btn.focus_entered.connect(grow)
	btn.focus_exited.connect(shrink)

# ── Controller / keyboard focus ───────────────────────────────────────────────

func _setup_focus() -> void:
	var chain : Array = [_play_btn, _settings_btn, _lang_btn, _quit_btn]
	for i in chain.size():
		var btn : Button = chain[i]
		btn.focus_mode = Control.FOCUS_ALL
		btn.focus_neighbor_top = chain[(i - 1 + chain.size()) % chain.size()].get_path()
		btn.focus_neighbor_bottom = chain[(i + 1) % chain.size()].get_path()

# ── Exit transition (main menu → character select) ────────────────────────────

func play_exit() -> Signal:
	for btn in [_play_btn, _settings_btn, _lang_btn, _quit_btn]:
		btn.disabled = true
		btn.focus_mode = Control.FOCUS_NONE
	var t := create_tween().set_parallel(true)
	for node in [_glow_lbl, _shadow_lbl, _title_lbl, _subtitle,
			_sep_line_l, _sep_line_r, _sep_gem, _topics_lbl] + _gems:
		t.tween_property(node, "modulate:a", 0.0, 0.28).set_ease(Tween.EASE_IN)
	t.tween_property(_title_lbl, "position:y", _title_lbl.position.y - 12.0, 0.32) \
		.set_ease(Tween.EASE_IN)
	var delay := 0.0
	for btn in [_play_btn, _settings_btn, _lang_btn, _quit_btn]:
		t.tween_property(btn, "modulate:a", 0.0, 0.22).set_delay(delay).set_ease(Tween.EASE_IN)
		t.tween_property(btn, "position:y", btn.position.y + 16.0, 0.26) \
			.set_delay(delay).set_ease(Tween.EASE_IN)
		delay += 0.04
	t.tween_property(_veil, "color:a", 1.0, 0.35)
	return t.finished
