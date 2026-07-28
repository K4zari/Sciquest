extends Control

signal topic_chosen(topic_id: int)
signal back_pressed

const ParallaxBackdrop := preload("res://scripts/parallax_backdrop.gd")

# ── Topic data ────────────────────────────────────────────────────────────────
const TOPICS := [
	{"id": 0,  "num": "T",  "name": "Tutorial",
	 "world": "Training Grounds",
	 "desc": "Learn to move,\nfight and use\nlevers!",
	 "color": Color(1.00, 0.84, 0.25),
	 "banner": "res://graphics/ui/menu/banner_plants.png"},
	{"id": 4,  "num": "4",  "name": "Plants",
	 "world": "Forest World",
	 "desc": "Learn about\nplants in the\nforest!",
	 "color": Color(0.18, 0.88, 0.32),
	 "banner": "res://graphics/ui/menu/banner_plants.png"},
	{"id": 5,  "num": "5",  "name": "Light",
	 "world": "Crystal Caves",
	 "desc": "Discover the\nsecrets of\nlight!",
	 "color": Color(0.14, 0.85, 1.00),
	 "banner": "res://graphics/ui/menu/banner_light.png"},
	{"id": 7,  "num": "7",  "name": "Energy",
	 "world": "Volcano Zone",
	 "desc": "Master energy\nin the\nvolcano zone!",
	 "color": Color(1.00, 0.45, 0.10),
	 "banner": "res://graphics/ui/menu/banner_energy.png"},
	{"id": 9,  "num": "9",  "name": "Earth",
	 "world": "Space & Planet",
	 "desc": "Explore space\nand learn\nabout Earth!",
	 "color": Color(0.28, 0.58, 1.00),
	 "banner": "res://graphics/ui/menu/banner_earth.png"},
	{"id": 10, "num": "10", "name": "Machines",
	 "world": "Steam Factory",
	 "desc": "Build and\nmaster all\nmachines!",
	 "color": Color(0.75, 0.35, 1.00),
	 "banner": "res://graphics/ui/menu/banner_machines.png"},
]

const C_BG      := Color(0.03, 0.05, 0.10)
const C_CARD_BG := Color(0.09, 0.14, 0.28)
const C_EDGE    := Color(0.12, 0.55, 0.82, 0.50)
const C_WHITE   := Color(1.00, 1.00, 1.00)
const C_BLACK   := Color(0.00, 0.00, 0.00)
const C_MUTED   := Color(0.45, 0.60, 0.72)
const C_DIM     := Color(0.30, 0.42, 0.55)

# ── Per-topic parallax backdrops (shown on card hover) ──────────────────────────
# Plants reuses the main-menu forest pack. The other four point at generated,
# depth-separated layer folders (back-to-front). `w`/`h` are the source texture
# dimensions used for seamless mirroring and bottom-framing.
const FOREST_LAYERS := [
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
# Shared on-screen framing height (px). Backdrops with a taller source canvas are
# scaled down to this so every topic's parallax is framed the same way on hover.
const FRAME_HEIGHT := 610.0
const PARALLAX := {
	0:  {"layers": FOREST_LAYERS, "w": 928.0, "h": 793.0},   # Tutorial — forest pack
	4:  {"layers": FOREST_LAYERS, "w": 928.0, "h": 793.0},   # Plants  — forest pack
	5:  {"layers": [
		"res://graphics/environment/parallax/light/layer_00_back.png",
		"res://graphics/environment/parallax/light/layer_01_mid.png",
		"res://graphics/environment/parallax/light/layer_02_fg.png",
	], "w": 928.0, "h": 610.0},                             # Light — Crystal Caves
	7:  {"layers": [
		"res://graphics/environment/parallax/energy/layer_00_back.png",
		"res://graphics/environment/parallax/energy/layer_01_mid.png",
		"res://graphics/environment/parallax/energy/layer_02_fg.png",
	], "w": 928.0, "h": 610.0},                             # Energy — Volcano Zone
	9:  {"layers": [
		"res://graphics/environment/parallax/earth/layer_00_back.png",
		"res://graphics/environment/parallax/earth/layer_01_mid.png",
		"res://graphics/environment/parallax/earth/layer_02_fg.png",
	], "w": 928.0, "h": 610.0},                             # Earth — Space & Planet
	10: {"layers": [
		"res://graphics/environment/parallax/machines/layer_00_back.png",
		"res://graphics/environment/parallax/machines/layer_01_mid.png",
		"res://graphics/environment/parallax/machines/layer_02_fg.png",
	], "w": 928.0, "h": 610.0},                             # Machines — Steam Factory
}

var _cards : Array = []
var _hit_btns : Array = []
var _back_btn : Button
var _overlay_tex : GradientTexture2D = null
var _selecting := false
var _backdrop : ParallaxBackdrop = null
var _tex_cache : Dictionary = {}   # topic_id -> Array[Texture2D]
var _hovered_id := -1

func _ready():
	var vp := get_viewport_rect().size
	size = vp
	position = Vector2.ZERO
	_preload_parallax()
	_build_ui(vp)
	_animate_entrance()

func _preload_parallax() -> void:
	for id in PARALLAX:
		var texes : Array = []
		for path in PARALLAX[id]["layers"]:
			var tex := load(path) as Texture2D
			if tex != null:
				texes.append(tex)
		_tex_cache[id] = texes

# ── Build ─────────────────────────────────────────────────────────────────────

func _build_ui(vp: Vector2) -> void:
	# Animated parallax backdrop (faded out until a card is hovered), with an
	# always-opaque dark base so the screen reads dark when nothing is hovered.
	_backdrop = ParallaxBackdrop.new()
	_backdrop.layer = -1
	add_child(_backdrop)
	_backdrop.set_base_color(C_BG, vp)

	# Readability scrim over the backdrop, behind all foreground UI. Semi-transparent
	# so the parallax still reads through it.
	var scrim := ColorRect.new()
	scrim.color = Color(0.02, 0.04, 0.09, 0.34)
	scrim.size = vp
	scrim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(scrim)

	# Faint centre glow
	for i in 3:
		var gr := ColorRect.new()
		var s := Vector2(500 - i * 100, 220 - i * 50)
		gr.size = s
		gr.position = (vp - s) * 0.5
		gr.color = Color(0.05, 0.25, 0.50, 0.04 - i * 0.01)
		add_child(gr)

	# Edge lines
	for y in [0.0, vp.y - 1.0]:
		var edge := ColorRect.new()
		edge.color = C_EDGE
		edge.size = Vector2(vp.x, 1)
		edge.position = Vector2(0, y)
		add_child(edge)

	# Header band
	var band := ColorRect.new()
	band.color = Color(0.04, 0.08, 0.16, 0.80)
	band.size = Vector2(vp.x, 52)
	add_child(band)
	var sep := ColorRect.new()
	sep.color = C_EDGE
	sep.size = Vector2(vp.x, 1)
	sep.position = Vector2(0, 52)
	add_child(sep)

	# Title
	var title_sh := _lbl(tr("Choose a Topic"), 22, C_BLACK)
	title_sh.size.x = vp.x
	title_sh.position = Vector2(2, 12)
	add_child(title_sh)

	var title := _lbl(tr("Choose a Topic"), 22, C_WHITE)
	title.add_theme_color_override("font_outline_color", C_BLACK)
	title.add_theme_constant_override("outline_size", 2)
	title.size.x = vp.x
	title.position = Vector2(0, 10)
	add_child(title)

	# Playing-as line
	var _name_map := {"male": "Ahmad", "female": "Aishah"}
	var char_name : String = _name_map.get(Globals.selected_character, Globals.selected_character.capitalize())
	var char_lbl := _lbl(tr("Playing as: {name}").format({"name": char_name}), 11, C_MUTED)
	char_lbl.size.x = vp.x
	char_lbl.position = Vector2(0, 34)
	add_child(char_lbl)

	# ── Cards ─────────────────────────────────────────────────────────────────
	var card_w  := 112.0
	var card_h  := 258.0
	var gap     := 8.0
	# Shrink cards if the row would overflow the viewport (6+ topics)
	var max_row_w := vp.x - 16.0
	if card_w * TOPICS.size() + gap * (TOPICS.size() - 1) > max_row_w:
		gap = 6.0
		card_w = floorf((max_row_w - gap * (TOPICS.size() - 1)) / TOPICS.size())
	var total_w := card_w * TOPICS.size() + gap * (TOPICS.size() - 1)
	var start_x := (vp.x - total_w) * 0.5
	var card_y  := 58.0

	for i in TOPICS.size():
		var panel := _make_card(
			Vector2(start_x + i * (card_w + gap), card_y),
			card_w, card_h, TOPICS[i])
		_cards.append(panel)

	# Back button
	_back_btn = Button.new()
	_back_btn.text = tr("< Back")
	_back_btn.position = Vector2(10, vp.y - 28)
	_back_btn.custom_minimum_size = Vector2(72, 22)
	_style_btn(_back_btn, Color(0.35, 0.35, 0.38))
	_pxfont(_back_btn, 11)
	_back_btn.pressed.connect(func(): back_pressed.emit())
	add_child(_back_btn)

	_setup_focus()

func _setup_focus() -> void:
	_back_btn.focus_mode = Control.FOCUS_ALL
	for i in _hit_btns.size():
		var hit : Button = _hit_btns[i]
		hit.focus_neighbor_left = _hit_btns[(i - 1 + _hit_btns.size()) % _hit_btns.size()].get_path()
		hit.focus_neighbor_right = _hit_btns[(i + 1) % _hit_btns.size()].get_path()
		hit.focus_neighbor_bottom = _back_btn.get_path()
	_back_btn.focus_neighbor_top = _hit_btns[0].get_path()

func _input(event):
	if event.is_action_pressed("ui_cancel") and not _selecting:
		get_viewport().set_input_as_handled()
		back_pressed.emit()

# ── Card factory ──────────────────────────────────────────────────────────────

func _make_card(pos: Vector2, w: float, h: float, topic: Dictionary) -> Panel:
	var accent : Color = topic.color

	var panel := Panel.new()
	panel.position = pos
	panel.size = Vector2(w, h)
	panel.custom_minimum_size = Vector2(w, h)
	panel.pivot_offset = Vector2(w * 0.5, h * 0.5)
	panel.clip_contents = true   # rounded corners clip the banner art

	var style := StyleBoxFlat.new()
	style.bg_color = C_CARD_BG
	style.border_color = accent
	style.set_border_width_all(3)        # thicker → reads as an artistic frame
	style.set_corner_radius_all(5)
	panel.add_theme_stylebox_override("panel", style)
	add_child(panel)

	# Themed banner art filling the card (falls back to the solid bg if missing)
	if topic.has("banner") and ResourceLoader.exists(topic.banner):
		var tex := load(topic.banner) as Texture2D
		if tex:
			var art := TextureRect.new()
			art.texture = tex
			art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
			art.size = Vector2(w, h)
			art.position = Vector2.ZERO
			art.mouse_filter = Control.MOUSE_FILTER_IGNORE
			panel.add_child(art)

	# Dark vertical gradient over the art so the text stays legible
	var overlay := TextureRect.new()
	overlay.texture = _card_overlay_tex()
	overlay.size = Vector2(w, h)
	overlay.position = Vector2.ZERO
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(overlay)

	# Dark "label plate" behind the upper text block so it stays crisp over art
	var plate := ColorRect.new()
	plate.color = Color(0.05, 0.07, 0.13, 0.74)
	plate.size = Vector2(w - 8, 164)
	plate.position = Vector2(4, 8)
	plate.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(plate)

	# Top accent bar
	var top_bar := ColorRect.new()
	top_bar.color = accent
	top_bar.size = Vector2(w - 4, 5)
	top_bar.position = Vector2(2, 2)
	panel.add_child(top_bar)

	# Inner top highlight
	var hl := ColorRect.new()
	hl.color = Color(1, 1, 1, 0.04)
	hl.size = Vector2(w - 4, 50)
	hl.position = Vector2(2, 7)
	panel.add_child(hl)

	# Decorative corner brackets (artistic outline accent)
	_add_corner_brackets(panel, w, h, accent)

	# "TOPIC" header label (small, muted)
	var topic_header := _lbl(tr("TOPIC"), 11, C_MUTED)
	topic_header.size.x = w
	topic_header.position = Vector2(0, 14)
	panel.add_child(topic_header)

	# Big topic number — accent colour with black outline
	var num_lbl := _lbl(topic.num, 33, accent)
	num_lbl.add_theme_color_override("font_outline_color", C_BLACK)
	num_lbl.add_theme_constant_override("outline_size", 3)
	num_lbl.size.x = w
	num_lbl.position = Vector2(0, 26)
	panel.add_child(num_lbl)

	# Separator under number
	var rule := ColorRect.new()
	rule.color = Color(accent.r, accent.g, accent.b, 0.30)
	rule.size = Vector2(w - 24, 1)
	rule.position = Vector2(12, 68)
	panel.add_child(rule)

	# Topic name (e.g. "Plants")
	var name_lbl := _lbl(tr(topic.name), 11, C_WHITE)
	name_lbl.add_theme_color_override("font_outline_color", C_BLACK)
	name_lbl.add_theme_constant_override("outline_size", 1)
	name_lbl.size.x = w
	name_lbl.position = Vector2(0, 74)
	panel.add_child(name_lbl)

	# World name (e.g. "Forest World"). Word-wraps so long translations
	# (e.g. Malay "Zon Gunung Berapi", "Angkasa & Planet") flow onto a second
	# line instead of being clipped by the card's edges.
	var world_lbl := _lbl(tr(topic.world), 11,
		Color(accent.r * 0.75, accent.g * 0.85, accent.b * 0.90))
	world_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	world_lbl.size.x = w
	world_lbl.position = Vector2(0, 90)
	panel.add_child(world_lbl)

	# Pushed down to leave room for a two-line world name above. Word-wrap so
	# long manual lines (e.g. Malay "Belajar bergerak,") flow to the next line
	# instead of being clipped by the card's edges.
	var desc_lbl := _lbl(tr(topic.desc), 11, Color(0.68, 0.78, 0.88))
	desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_lbl.size.x = w
	desc_lbl.position = Vector2(0, 122)
	panel.add_child(desc_lbl)

	# Completed badge
	if Globals.completed_topics.has(topic.id):
		var done := _lbl(tr("  CLEAR  "), 11, Color(0.20, 1.00, 0.45))
		done.add_theme_color_override("font_outline_color", C_BLACK)
		done.add_theme_constant_override("outline_size", 1)
		done.size.x = w
		done.position = Vector2(0, h - 58)
		panel.add_child(done)

	# "▶ PLAY" hover hint — hidden until the card is hovered
	var hint := _lbl(tr("> PLAY"), 11, accent)
	hint.add_theme_color_override("font_outline_color", C_BLACK)
	hint.add_theme_constant_override("outline_size", 1)
	hint.size.x = w
	hint.position = Vector2(0, h - 30)
	hint.modulate.a = 0.0
	panel.add_child(hint)

	# Whole-card hover/click/focus target (transparent button over everything;
	# focus feedback comes from the hover lift + backdrop, not a stylebox)
	var hit := Button.new()
	hit.flat = true
	hit.focus_mode = Control.FOCUS_ALL
	hit.size = Vector2(w, h)
	hit.position = Vector2.ZERO
	var empty := StyleBoxEmpty.new()
	for s in ["normal", "hover", "pressed", "focus"]:
		hit.add_theme_stylebox_override(s, empty)
	hit.mouse_entered.connect(_on_card_hover.bind(panel, hint, topic.id))
	hit.mouse_exited.connect(_on_card_unhover.bind(panel, hint))
	hit.focus_entered.connect(_on_card_hover.bind(panel, hint, topic.id))
	hit.focus_exited.connect(_on_card_unhover.bind(panel, hint))
	hit.pressed.connect(_on_play_pressed.bind(topic.id, panel))
	panel.add_child(hit)
	_hit_btns.append(hit)

	return panel

# ── Decorative frame ──────────────────────────────────────────────────────────

func _add_corner_brackets(panel: Panel, w: float, h: float, accent: Color) -> void:
	const LEN := 12.0
	const THK := 2.0
	const PAD := 4.0
	var corners := [
		[Vector2(PAD, PAD),                   1,  1],   # top-left
		[Vector2(w - PAD, PAD),              -1,  1],   # top-right
		[Vector2(PAD, h - PAD),               1, -1],   # bottom-left
		[Vector2(w - PAD, h - PAD),          -1, -1],   # bottom-right
	]
	for c in corners:
		var origin : Vector2 = c[0]
		var sx : int = c[1]
		var sy : int = c[2]
		# Horizontal arm
		var harm := ColorRect.new()
		harm.color = accent
		harm.mouse_filter = Control.MOUSE_FILTER_IGNORE
		harm.size = Vector2(LEN, THK)
		harm.position = origin + Vector2(0 if sx > 0 else -LEN, 0 if sy > 0 else -THK)
		panel.add_child(harm)
		# Vertical arm
		var varm := ColorRect.new()
		varm.color = accent
		varm.mouse_filter = Control.MOUSE_FILTER_IGNORE
		varm.size = Vector2(THK, LEN)
		varm.position = origin + Vector2(0 if sx > 0 else -THK, 0 if sy > 0 else -LEN)
		panel.add_child(varm)

func _card_overlay_tex() -> GradientTexture2D:
	if _overlay_tex != null:
		return _overlay_tex
	var grad := Gradient.new()
	grad.set_offset(0, 0.0)
	grad.set_offset(1, 1.0)
	grad.set_color(0, Color(0.02, 0.04, 0.09, 0.22))   # lighter at top
	grad.set_color(1, Color(0.02, 0.04, 0.09, 0.55))   # showcase art in lower half
	_overlay_tex = GradientTexture2D.new()
	_overlay_tex.gradient = grad
	_overlay_tex.fill_from = Vector2(0, 0)
	_overlay_tex.fill_to = Vector2(0, 1)
	return _overlay_tex

# ── Hover-to-play ─────────────────────────────────────────────────────────────

func _on_card_hover(panel: Panel, hint: Label, topic_id: int) -> void:
	if _selecting:
		return
	var t := create_tween().set_parallel(true) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	t.tween_property(panel, "scale", Vector2(1.06, 1.06), 0.14)
	t.tween_property(panel, "modulate", Color(1.18, 1.18, 1.18), 0.14)
	create_tween().tween_property(hint, "modulate:a", 1.0, 0.14)
	_show_backdrop(topic_id)

func _on_card_unhover(panel: Panel, hint: Label) -> void:
	if _selecting:
		return
	var t := create_tween().set_parallel(true) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	t.tween_property(panel, "scale", Vector2(1.0, 1.0), 0.14)
	t.tween_property(panel, "modulate", C_WHITE, 0.14)
	create_tween().tween_property(hint, "modulate:a", 0.0, 0.14)
	_hide_backdrop()

# ── Hover backdrop ──────────────────────────────────────────────────────────────

func _show_backdrop(topic_id: int) -> void:
	if _backdrop == null:
		return
	# Rebuild layers only when the hovered topic actually changes.
	if topic_id != _hovered_id or not _backdrop.has_layers():
		var texes : Array = _tex_cache.get(topic_id, [])
		if texes.is_empty():
			return
		var cfg : Dictionary = PARALLAX[topic_id]
		# Normalise every backdrop to a common on-screen framing height so taller
		# source sets (the 793px forest pack) aren't shown more zoomed-in/cropped
		# than the 610px painted sets. Scale tall art down to the shared frame.
		var frame_scale : float = min(1.0, FRAME_HEIGHT / float(cfg["h"]))
		_backdrop.set_layers(texes, cfg["w"], cfg["h"], get_viewport_rect().size, 8.0, frame_scale)
		_hovered_id = topic_id
	_backdrop.fade_in()

func _hide_backdrop() -> void:
	if _backdrop != null:
		_backdrop.fade_out()

# ── Entrance animation ────────────────────────────────────────────────────────

func _animate_entrance() -> void:
	for card in _cards:
		(card as Panel).scale = Vector2(0.55, 0.55)
		(card as Panel).modulate.a = 0.0

	var t := create_tween().set_parallel(true)
	for i in _cards.size():
		var delay := 0.06 + i * 0.08
		t.tween_property(_cards[i], "scale",      Vector2(1.0, 1.0), 0.42) \
			.set_delay(delay).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
		t.tween_property(_cards[i], "modulate:a", 1.0, 0.28) \
			.set_delay(delay).set_ease(Tween.EASE_OUT)

	t.finished.connect(func(): (_hit_btns[0] as Button).grab_focus())

# ── Play animation ────────────────────────────────────────────────────────────

func _on_play_pressed(topic_id: int, panel: Panel) -> void:
	if _selecting:
		return
	_selecting = true   # freeze hover handlers during the select animation

	# Dim all other cards
	for card in _cards:
		if card != panel:
			create_tween().tween_property(card, "modulate:a", 0.20, 0.15)

	# Bounce the selected card then flash
	var t := create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	t.tween_property(panel, "scale", Vector2(1.12, 1.12), 0.14)
	t.tween_property(panel, "scale", Vector2(1.04, 1.04), 0.10)
	t.finished.connect(func():
		var flash := create_tween()
		flash.tween_property(panel, "modulate", Color(1.5, 1.5, 1.5), 0.08)
		flash.tween_property(panel, "modulate", Color.WHITE,           0.10)
		flash.finished.connect(func(): topic_chosen.emit(topic_id))
	)

# ── Helpers ───────────────────────────────────────────────────────────────────

func _lbl(text: String, fs: int, color: Color) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_color_override("font_color", color)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_pxfont(l, fs)
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
	btn.add_theme_color_override("font_color",         Color(0.92, 0.95, 1.00))
	btn.add_theme_color_override("font_hover_color",   Color(1.00, 1.00, 1.00))
	btn.add_theme_color_override("font_pressed_color", Color(0.60, 0.70, 0.80))
