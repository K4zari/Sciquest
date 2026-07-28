extends Control

signal character_chosen
signal back_pressed

const FRAME_W     := 74
const FRAME_H     := 44
const IDLE_FRAMES := 6
const SPR_SCALE   := 2.0

# ── Palette ───────────────────────────────────────────────────────────────────
const C_BG       := Color(0.03, 0.05, 0.10)
const C_CARD_BG  := Color(0.09, 0.14, 0.28)   # clearly lighter than background
const C_TITLE    := Color(1.00, 1.00, 1.00)
const C_OUTLINE  := Color(0.00, 0.00, 0.00)
const C_SHADOW   := Color(0.00, 0.00, 0.00, 0.80)
const C_SUBTITLE := Color(0.45, 0.62, 0.72)
const C_EDGE     := Color(0.12, 0.55, 0.82, 0.50)
const C_AHMAD    := Color(0.14, 0.85, 1.00)
const C_AISHAH   := Color(0.72, 0.38, 1.00)
const C_NAME     := Color(1.00, 1.00, 1.00)
const C_BACK     := Color(0.35, 0.35, 0.38)

var _panel_ahmad : Panel
var _panel_aishah : Panel
var _select_btns : Array = []
var _back_btn : Button
var _chosen : bool = false

func _ready():
	var vp := get_viewport_rect().size
	size = vp
	position = Vector2.ZERO
	_build_ui(vp)
	_animate_entrance()

# ── Build ─────────────────────────────────────────────────────────────────────

func _build_ui(vp: Vector2) -> void:
	var bg := ColorRect.new()
	bg.color = C_BG
	bg.size = vp
	add_child(bg)

	# Faint blue centre glow
	for i in 3:
		var gr := ColorRect.new()
		var s := Vector2(400 - i * 80, 200 - i * 40)
		gr.size = s
		gr.position = (vp - s) * 0.5 + Vector2(0, -10)
		gr.color = Color(0.05, 0.25, 0.50, 0.04 - i * 0.01)
		add_child(gr)

	# Edge lines
	for y in [0.0, vp.y - 1.0]:
		var edge := ColorRect.new()
		edge.color = C_EDGE
		edge.size = Vector2(vp.x, 1)
		edge.position = Vector2(0, y)
		add_child(edge)

	# Header
	var band := ColorRect.new()
	band.color = Color(0.04, 0.08, 0.16, 0.80)
	band.size = Vector2(vp.x, 52)
	add_child(band)
	var sep := ColorRect.new()
	sep.color = C_EDGE
	sep.size = Vector2(vp.x, 1)
	sep.position = Vector2(0, 52)
	add_child(sep)

	# Title shadow then main
	var title_sh := Label.new()
	title_sh.text = tr("Choose Your Hero")
	title_sh.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_sh.size.x = vp.x
	title_sh.position = Vector2(2, 12)
	title_sh.add_theme_color_override("font_color", C_SHADOW)
	_pxfont(title_sh, 22)
	add_child(title_sh)

	var title := Label.new()
	title.text = tr("Choose Your Hero")
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.size.x = vp.x
	title.position = Vector2(0, 10)
	title.add_theme_color_override("font_color", C_TITLE)
	title.add_theme_color_override("font_outline_color", C_OUTLINE)
	title.add_theme_constant_override("outline_size", 2)
	_pxfont(title, 22)
	add_child(title)

	var subtitle := Label.new()
	subtitle.text = tr("Select your adventurer")
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.size.x = vp.x
	subtitle.position = Vector2(0, 34)
	subtitle.add_theme_color_override("font_color", C_SUBTITLE)
	_pxfont(subtitle, 11)
	add_child(subtitle)

	# ── Cards ─────────────────────────────────────────────────────────────────
	var card_w  := 148.0
	var card_h  := 196.0
	var gap     := 44.0
	var total_w := card_w * 2.0 + gap
	var start_x := (vp.x - total_w) * 0.5
	var card_y  := (vp.y - card_h) * 0.5 + 12.0

	_panel_ahmad = _make_card(
		Vector2(start_x, card_y), card_w, card_h,
		"Ahmad", "Warrior", "male",
		"res://graphics/spritesheets/sciquest_ahmad.png", C_AHMAD)

	_panel_aishah = _make_card(
		Vector2(start_x + card_w + gap, card_y), card_w, card_h,
		"Aishah", "Explorer", "female",
		"res://graphics/spritesheets/sciquest_aishah.png", C_AISHAH)

	# Back button
	_back_btn = Button.new()
	_back_btn.text = tr("< Back")
	_back_btn.position = Vector2(10, vp.y - 30)
	_back_btn.custom_minimum_size = Vector2(72, 22)
	_style_btn(_back_btn, C_BACK)
	_pxfont(_back_btn, 11)
	_back_btn.pressed.connect(func(): back_pressed.emit())
	add_child(_back_btn)

	_setup_focus()

func _setup_focus() -> void:
	var left : Button = _select_btns[0]
	var right : Button = _select_btns[1]
	for btn in [left, right, _back_btn]:
		btn.focus_mode = Control.FOCUS_ALL
	left.focus_neighbor_right = right.get_path()
	left.focus_neighbor_left = right.get_path()
	left.focus_neighbor_bottom = _back_btn.get_path()
	right.focus_neighbor_left = left.get_path()
	right.focus_neighbor_right = left.get_path()
	right.focus_neighbor_bottom = _back_btn.get_path()
	_back_btn.focus_neighbor_top = left.get_path()

func _input(event):
	if event.is_action_pressed("ui_cancel") and not _chosen:
		get_viewport().set_input_as_handled()
		back_pressed.emit()

# ── Card factory ──────────────────────────────────────────────────────────────

func _make_card(pos: Vector2, w: float, h: float,
		char_name: String, char_role: String, char_key: String,
		sheet_path: String, accent: Color) -> Panel:

	var panel := Panel.new()
	panel.position = pos
	panel.custom_minimum_size = Vector2(w, h)
	panel.size = Vector2(w, h)
	# Pivot at card centre so scale animation pops from the middle
	panel.pivot_offset = Vector2(w * 0.5, h * 0.5)

	var style := StyleBoxFlat.new()
	style.bg_color = C_CARD_BG
	style.border_color = accent
	style.set_border_width_all(2)
	style.set_corner_radius_all(4)
	panel.add_theme_stylebox_override("panel", style)
	add_child(panel)

	# Inner top highlight — makes the card feel lit from above
	var top_hl := ColorRect.new()
	top_hl.color = Color(1.0, 1.0, 1.0, 0.05)
	top_hl.size = Vector2(w - 4, 38)
	top_hl.position = Vector2(2, 2)
	panel.add_child(top_hl)

	# Accent bar across the very top edge
	var top_bar := ColorRect.new()
	top_bar.color = Color(accent.r, accent.g, accent.b, 0.55)
	top_bar.size = Vector2(w - 4, 2)
	top_bar.position = Vector2(2, 2)
	panel.add_child(top_bar)

	# Character sprite
	if ResourceLoader.exists(sheet_path):
		var tex := load(sheet_path) as Texture2D
		var frames := SpriteFrames.new()
		frames.add_animation("idle")
		frames.set_animation_speed("idle", 8.0)
		frames.set_animation_loop("idle", true)
		for i in IDLE_FRAMES:
			var atlas := AtlasTexture.new()
			atlas.atlas = tex
			atlas.region = Rect2(i * FRAME_W, 0, FRAME_W, FRAME_H)
			frames.add_frame("idle", atlas)
		var anim := AnimatedSprite2D.new()
		anim.sprite_frames = frames
		anim.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		anim.scale = Vector2(SPR_SCALE, SPR_SCALE)
		anim.position = Vector2(w * 0.5, 65.0)
		anim.offset = Vector2(10.0, 0.0)
		anim.play("idle")
		panel.add_child(anim)

	# Divider
	var rule := ColorRect.new()
	rule.color = Color(accent.r, accent.g, accent.b, 0.30)
	rule.size = Vector2(w - 24, 1)
	rule.position = Vector2(12, 116)
	panel.add_child(rule)

	# Name
	var name_lbl := Label.new()
	name_lbl.text = char_name
	name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_lbl.size.x = w
	name_lbl.position = Vector2(0, 122)
	name_lbl.add_theme_color_override("font_color", C_NAME)
	name_lbl.add_theme_color_override("font_outline_color", C_OUTLINE)
	name_lbl.add_theme_constant_override("outline_size", 2)
	_pxfont(name_lbl, 16)
	panel.add_child(name_lbl)

	# Role
	var role_lbl := Label.new()
	role_lbl.text = tr(char_role)
	role_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	role_lbl.size.x = w
	role_lbl.position = Vector2(0, 142)
	role_lbl.add_theme_color_override("font_color",
		Color(accent.r * 0.75, accent.g * 0.85, accent.b * 0.90))
	_pxfont(role_lbl, 11)
	panel.add_child(role_lbl)

	# SELECT button
	var btn := Button.new()
	btn.text = tr("SELECT")
	btn.position = Vector2(14, 160)
	btn.custom_minimum_size = Vector2(w - 28, 26)
	_style_btn(btn, accent)
	_pxfont(btn, 11)
	btn.pressed.connect(_on_card_selected.bind(char_key, panel))
	panel.add_child(btn)
	_select_btns.append(btn)

	return panel

# ── Entrance animation ────────────────────────────────────────────────────────

func _animate_entrance() -> void:
	for panel in [_panel_ahmad, _panel_aishah]:
		(panel as Panel).scale = Vector2(0.55, 0.55)
		(panel as Panel).modulate.a = 0.0

	var t := create_tween().set_parallel(true)

	t.tween_property(_panel_ahmad, "scale",      Vector2(1.0, 1.0), 0.45) \
		.set_delay(0.10).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	t.tween_property(_panel_ahmad, "modulate:a", 1.0, 0.30) \
		.set_delay(0.10).set_ease(Tween.EASE_OUT)

	t.tween_property(_panel_aishah, "scale",      Vector2(1.0, 1.0), 0.45) \
		.set_delay(0.26).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	t.tween_property(_panel_aishah, "modulate:a", 1.0, 0.30) \
		.set_delay(0.26).set_ease(Tween.EASE_OUT)

	t.finished.connect(func(): (_select_btns[0] as Button).grab_focus())

# ── Selection animation ───────────────────────────────────────────────────────

func _on_card_selected(char_key: String, panel: Panel) -> void:
	if _chosen:
		return
	_chosen = true
	for btn in _select_btns:
		(btn as Button).disabled = true
	Globals.selected_character = char_key

	# Dim the other card
	var other := _panel_aishah if panel == _panel_ahmad else _panel_ahmad
	var dim := create_tween()
	dim.tween_property(other, "modulate:a", 0.25, 0.15)

	# Bounce the selected card: pop up, shrink back, then hold slightly larger
	var t := create_tween() \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	t.tween_property(panel, "scale", Vector2(1.14, 1.14), 0.14)
	t.tween_property(panel, "scale", Vector2(1.05, 1.05), 0.12)

	# Flash the border bright then emit the signal
	t.finished.connect(func():
		var flash := create_tween()
		flash.tween_property(panel, "modulate",
			Color(1.4, 1.4, 1.4), 0.08)
		flash.tween_property(panel, "modulate",
			Color.WHITE, 0.10)
		flash.finished.connect(func(): character_chosen.emit())
	)

# ── Helpers ───────────────────────────────────────────────────────────────────

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
	btn.add_theme_stylebox_override("normal",  mk.call(0.20))
	btn.add_theme_stylebox_override("hover",   mk.call(0.38))
	btn.add_theme_stylebox_override("pressed", mk.call(0.12))
	btn.add_theme_stylebox_override("focus",   mk.call(0.38))
	btn.add_theme_color_override("font_color",         Color(0.92, 0.95, 1.00))
	btn.add_theme_color_override("font_hover_color",   Color(1.00, 1.00, 1.00))
	btn.add_theme_color_override("font_pressed_color", Color(0.60, 0.70, 0.80))
