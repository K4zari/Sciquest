extends CanvasLayer
class_name LevelCompleteScreen

## The end-of-level celebration screen. Built to match the SciQuest menu theme:
## pixel font, white-with-black-outline headline, cyan/gold accents, and a lively
## animated reveal (panel pop-in, confetti, stars that pop one-by-one, count-up
## stats, and a praise banner) so finishing a level feels like a reward.

signal continue_pressed

const FONT_PATH := "res://fonts/m6x11 Daniel LInssen.ttf"

# ── Palette (shared language with main_menu.gd) ─────────────────────────────
const C_PANEL    := Color(0.06, 0.08, 0.15, 0.98)
const C_PANEL2   := Color(0.04, 0.05, 0.10, 1.0)
const C_BORDER   := Color(0.22, 0.80, 0.98)
const C_WHITE    := Color(1, 1, 1)
const C_OUTLINE  := Color(0, 0, 0)
const C_GOLD     := Color(1.00, 0.83, 0.28)
const C_GOLD_GLOW:= Color(1.00, 0.70, 0.15, 0.18)
const C_STAR_OFF := Color(0.20, 0.24, 0.33)
const C_SUB      := Color(0.55, 0.75, 0.88)
const C_GREEN    := Color(0.42, 1.00, 0.55)
const C_RED      := Color(1.00, 0.50, 0.45)
const C_PURPLE   := Color(0.74, 0.62, 1.00)
const C_CYAN     := Color(0.40, 0.85, 1.00)
const C_GREY     := Color(0.72, 0.74, 0.82)
const C_BTN      := Color(0.10, 0.62, 0.92)

const PANEL_W := 300.0
const PANEL_H := 268.0

const PRAISE := {
	3: ["STELLAR WORK!", "SCIENCE STAR!", "OUTSTANDING!"],
	2: ["WELL DONE!", "GREAT JOB!", "NICELY DONE!"],
	1: ["LEVEL CLEAR!", "YOU DID IT!", "MISSION DONE!"]
}

var _dim : ColorRect
var _root : Control          # screen-space layer for confetti + sparkles
var _panel : Panel
var _topic : Label
var _praise : Label
var _new_best : Label
var _stars : Array = []
var _continue_button : Button
var _time_value : Label
var _correct_value : Label
var _enemies_value : Label
var _deaths_value : Label

var _elapsed : int = 0
var _correct : int = 0
var _total : int = 0
var _enemies : int = 0
var _enemies_total : int = 0
var _deaths : int = 0
var _done : bool = false

func _ready():
	layer = 20

func setup(stats : Dictionary):
	_correct = stats.get("correct", 0)
	_total = stats.get("total", 0)
	_deaths = stats.get("deaths", 0)
	_enemies = stats.get("enemies_defeated", 0)
	_enemies_total = stats.get("enemies_total", 0)
	_elapsed = int(stats.get("elapsed", 0.0))
	var topic_id : int = stats.get("topic_id", Globals.current_topic)

	var stars : int = _compute_stars(_correct, _total, _deaths, _enemies, _enemies_total)
	var is_new_best : bool = Globals.record_stars(topic_id, stars)
	var praise_pool : Array = PRAISE[stars]
	var praise_text : String = tr(praise_pool[randi() % praise_pool.size()])

	_build(topic_id, praise_text)
	_animate_in(stars, is_new_best)

# ── Build ───────────────────────────────────────────────────────────────────

func _build(topic_id : int, praise_text : String) -> void:
	var vp := get_viewport().get_visible_rect().size

	_dim = ColorRect.new()
	_dim.color = Color(0.02, 0.03, 0.07, 0.0)
	_dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	_dim.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_dim)

	_make_ambient_twinkles(vp)

	var origin := (vp - Vector2(PANEL_W, PANEL_H)) * 0.5
	_panel = Panel.new()
	_panel.add_theme_stylebox_override("panel", _panel_style())
	_panel.size = Vector2(PANEL_W, PANEL_H)
	_panel.position = origin
	_panel.pivot_offset = Vector2(PANEL_W, PANEL_H) * 0.5
	add_child(_panel)

	# Decorative corner gems + header underline.
	for c in [Vector2(8, 8), Vector2(PANEL_W - 14, 8), Vector2(8, PANEL_H - 18), Vector2(PANEL_W - 14, PANEL_H - 18)]:
		var gem := _glyph("◆", 9, C_BORDER)
		gem.position = c
		_panel.add_child(gem)

	# Header glow + headline.
	var glow := _text(tr("LEVEL COMPLETE!"), 23, C_GOLD_GLOW, 14)
	glow.position.y = 15
	var header := _text(tr("LEVEL COMPLETE!"), 22, C_WHITE, 14)
	header.add_theme_color_override("font_outline_color", C_OUTLINE)
	header.add_theme_constant_override("outline_size", 4)
	header.position.y = 16

	var underline := ColorRect.new()
	underline.color = C_BORDER
	underline.size = Vector2(120, 1)
	underline.position = Vector2((PANEL_W - 120) * 0.5, 44)
	_panel.add_child(underline)

	_topic = _text(QuestionBank.get_topic_name(topic_id).to_upper(), 9, C_SUB, 50)
	_topic.modulate.a = 0.0

	# Stars row.
	var spacing := 56.0
	var cx := PANEL_W * 0.5
	for i in 3:
		var star := _glyph("★", 34, C_STAR_OFF)
		star.size = Vector2(44, 44)
		star.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		star.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		star.position = Vector2(cx + (i - 1) * spacing - 22, 64)
		star.pivot_offset = Vector2(22, 22)
		star.scale = Vector2.ZERO
		_panel.add_child(star)
		_stars.append(star)

	_praise = _text(praise_text, 15, C_GOLD, 114)
	_praise.add_theme_color_override("font_outline_color", C_OUTLINE)
	_praise.add_theme_constant_override("outline_size", 3)
	_praise.pivot_offset = Vector2(PANEL_W * 0.5, 11)
	_praise.scale = Vector2.ZERO

	_new_best = _text(tr("◆ NEW BEST ◆"), 10, C_GREEN, 136)
	_new_best.pivot_offset = Vector2(PANEL_W * 0.5, 8)
	_new_best.scale = Vector2.ZERO

	# Stats panel.
	var stats_bg := Panel.new()
	stats_bg.add_theme_stylebox_override("panel", _stats_style())
	stats_bg.size = Vector2(244, 78)
	stats_bg.position = Vector2((PANEL_W - 244) * 0.5, 154)
	_panel.add_child(stats_bg)

	_time_value = _stat_row(tr("TIME"), C_CYAN, 162)
	_correct_value = _stat_row(tr("CORRECT"), C_GREEN, 180)
	_enemies_value = _stat_row(tr("ENEMIES"), C_PURPLE, 198)
	_deaths_value = _stat_row(tr("DEATHS"), C_GREY, 216)
	_time_value.text = "0:00"
	_correct_value.text = "0 / %d" % _total
	_enemies_value.text = ("0 / %d" % _enemies_total) if _enemies_total > 0 else "0"
	_deaths_value.text = "0"

	# Continue button.
	_continue_button = Button.new()
	_continue_button.text = tr("CONTINUE  ►")
	_continue_button.size = Vector2(160, 26)
	_continue_button.position = Vector2((PANEL_W - 160) * 0.5, 236)
	_continue_button.pivot_offset = Vector2(80, 13)
	_style_button(_continue_button, C_BTN)
	_continue_button.modulate.a = 0.0
	_continue_button.pressed.connect(_on_continue_pressed)
	_panel.add_child(_continue_button)

	# Front layer for confetti / star sparkles.
	_root = Control.new()
	_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_root)

# ── Entrance choreography ──────────────────────────────────────────────────

func _animate_in(stars_filled : int, is_new_best : bool) -> void:
	AudioManager.play_sfx("level_complete")
	create_tween().tween_property(_dim, "color:a", 0.74, 0.25)

	_panel.scale = Vector2(0.55, 0.55)
	_panel.modulate.a = 0.0
	var pt := create_tween().set_parallel(true)
	pt.tween_property(_panel, "modulate:a", 1.0, 0.20).set_delay(0.05)
	pt.tween_property(_panel, "scale", Vector2.ONE, 0.50).set_delay(0.05) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

	await get_tree().create_timer(0.12).timeout
	_spawn_confetti(28)
	await get_tree().create_timer(0.30).timeout

	create_tween().tween_property(_topic, "modulate:a", 1.0, 0.25)

	for i in 3:
		await get_tree().create_timer(0.18).timeout
		_pop_star(_stars[i], i < stars_filled)

	await get_tree().create_timer(0.12).timeout
	_pop_in(_praise, 0.34)
	_run_counters()
	if stars_filled >= 3:
		_spawn_confetti(22)

	if is_new_best:
		await get_tree().create_timer(0.16).timeout
		_pop_in(_new_best, 0.36)
		_start_blink(_new_best)

	await get_tree().create_timer(0.20).timeout
	var bt := create_tween()
	bt.tween_property(_continue_button, "modulate:a", 1.0, 0.30)
	_continue_button.grab_focus.call_deferred()
	_start_button_pulse()

func _pop_star(star : Label, filled : bool) -> void:
	star.text = "★" if filled else "☆"
	star.add_theme_color_override("font_color", C_GOLD if filled else C_STAR_OFF)
	var t := create_tween()
	t.tween_property(star, "scale", Vector2(1.45, 1.45), 0.16) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	t.tween_property(star, "scale", Vector2.ONE, 0.14).set_trans(Tween.TRANS_SINE)
	if filled:
		var f := create_tween()
		f.tween_property(star, "self_modulate", Color(2.2, 2.2, 2.2), 0.08)
		f.tween_property(star, "self_modulate", C_WHITE, 0.30)
		_star_sparkles(star)
		_start_star_pulse(star)

func _run_counters() -> void:
	_count(_time_value, _elapsed, 0.8, func(v): return _format_time(v))
	_count_pair(_correct_value, _correct, _total, 0.8)
	if _enemies_total > 0:
		_count_pair(_enemies_value, _enemies, _enemies_total, 0.7)
	else:
		_count(_enemies_value, _enemies, 0.7, func(v): return str(v))
	_count(_deaths_value, _deaths, 0.6, func(v): return str(v))

func _count(label : Label, to : int, dur : float, fmt : Callable) -> void:
	if to <= 0:
		label.text = fmt.call(0)
		return
	var t := create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	t.tween_method(func(v): label.text = fmt.call(int(round(v))), 0.0, float(to), dur)

func _count_pair(label : Label, correct : int, total : int, dur : float) -> void:
	if correct <= 0:
		label.text = "0 / %d" % total
		return
	var t := create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	t.tween_method(func(v): label.text = "%d / %d" % [int(round(v)), total], 0.0, float(correct), dur)

# ── Idle / juice loops ─────────────────────────────────────────────────────

func _start_button_pulse() -> void:
	var t := create_tween().set_loops().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	t.tween_property(_continue_button, "scale", Vector2(1.05, 1.05), 0.6)
	t.tween_property(_continue_button, "scale", Vector2.ONE, 0.6)

func _start_star_pulse(star : Label) -> void:
	var t := create_tween().set_loops().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	t.tween_property(star, "self_modulate", Color(1.25, 1.20, 1.0), 1.1)
	t.tween_property(star, "self_modulate", Color(0.92, 0.92, 1.0), 1.1)

func _start_blink(node : CanvasItem) -> void:
	var t := create_tween().set_loops().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	t.tween_property(node, "modulate:a", 0.35, 0.5)
	t.tween_property(node, "modulate:a", 1.0, 0.5)

func _star_sparkles(star : Label) -> void:
	var center : Vector2 = _panel.position + star.position + star.size * 0.5
	for i in 5:
		var s := _glyph("✦", randi_range(7, 11), C_GOLD)
		s.position = center
		s.pivot_offset = s.size * 0.5
		_root.add_child(s)
		var ang := randf() * TAU
		var dist := randf_range(14.0, 26.0)
		var t := create_tween().set_parallel(true)
		t.tween_property(s, "position", center + Vector2(cos(ang), sin(ang)) * dist, 0.45) \
			.set_ease(Tween.EASE_OUT)
		t.tween_property(s, "modulate:a", 0.0, 0.45)
		t.chain().tween_callback(s.queue_free)

func _spawn_confetti(count : int) -> void:
	var vp := get_viewport().get_visible_rect().size
	var cols := [C_CYAN, C_GOLD, C_GREEN, Color(1.0, 0.55, 0.65), C_WHITE, C_PURPLE]
	for i in count:
		var p := ColorRect.new()
		p.color = cols[randi() % cols.size()]
		p.size = Vector2(randf_range(3, 5), randf_range(3, 6))
		p.pivot_offset = p.size * 0.5
		var sx := vp.x * 0.5 + randf_range(-70, 70)
		var sy := vp.y * 0.20 + randf_range(-12, 12)
		p.position = Vector2(sx, sy)
		p.rotation = randf_range(0, TAU)
		_root.add_child(p)
		var dur := randf_range(1.0, 1.9)
		var move := create_tween().set_parallel(true)
		move.tween_property(p, "position", Vector2(sx + randf_range(-100, 100), vp.y + 24), dur) \
			.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
		move.tween_property(p, "rotation", p.rotation + randf_range(-9, 9), dur)
		var fade := create_tween()
		fade.tween_interval(dur * 0.55)
		fade.tween_property(p, "modulate:a", 0.0, dur * 0.45)
		fade.tween_callback(p.queue_free)

func _make_ambient_twinkles(vp : Vector2) -> void:
	var spots := [
		Vector2(0.12, 0.16), Vector2(0.86, 0.14), Vector2(0.20, 0.82),
		Vector2(0.80, 0.80), Vector2(0.10, 0.50), Vector2(0.90, 0.46),
		Vector2(0.30, 0.10), Vector2(0.70, 0.88),
	]
	for sp in spots:
		var star := _glyph("✦", 8, C_CYAN)
		star.position = vp * sp
		star.modulate.a = 0.0
		add_child(star)
		var delay := randf_range(0.0, 3.0)
		var t := create_tween().set_loops()
		t.tween_interval(delay)
		t.tween_property(star, "modulate:a", randf_range(0.3, 0.7), 0.6).set_ease(Tween.EASE_OUT)
		t.tween_property(star, "modulate:a", 0.0, 0.9).set_ease(Tween.EASE_IN)
		t.tween_interval(randf_range(0.6, 2.4))

# ── Helpers ─────────────────────────────────────────────────────────────────

func _pop_in(node : Control, dur : float) -> void:
	node.scale = Vector2.ZERO
	var t := create_tween()
	t.tween_property(node, "scale", Vector2.ONE, dur).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

func _stat_row(name_text : String, accent : Color, y : float) -> Label:
	var dot := _glyph("◆", 7, accent)
	dot.position = Vector2(36, y + 3)
	_panel.add_child(dot)

	var name_label := _text_raw(name_text, 10, accent)
	name_label.position = Vector2(48, y)
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	_apply_pixel_font(name_label, 10)
	_panel.add_child(name_label)

	var value := _text_raw("-", 10, C_WHITE)
	value.position = Vector2(PANEL_W - 152, y)
	value.size.x = 116
	value.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_apply_pixel_font(value, 10)
	_panel.add_child(value)
	return value

## Centered, pixel-font text label spanning the panel width, added to the panel.
func _text(s : String, fs : int, color : Color, y : float) -> Label:
	var l := _text_raw(s, fs, color)
	l.size = Vector2(PANEL_W, fs + 8)
	l.position = Vector2(0, y)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_apply_pixel_font(l, fs)
	_panel.add_child(l)
	return l

func _text_raw(s : String, fs : int, color : Color) -> Label:
	var l := Label.new()
	l.text = s
	l.add_theme_font_size_override("font_size", fs)
	l.add_theme_color_override("font_color", color)
	return l

## Glyph label (★ ◆ ✦) — keeps the default font, which carries these symbols.
func _glyph(s : String, fs : int, color : Color) -> Label:
	var l := Label.new()
	l.text = s
	l.add_theme_font_size_override("font_size", fs)
	l.add_theme_color_override("font_color", color)
	return l

func _apply_pixel_font(lbl : Control, size : int) -> void:
	var f := load(FONT_PATH) as FontFile
	if f == null:
		return
	f = f.duplicate() as FontFile
	f.antialiasing = TextServer.FONT_ANTIALIASING_NONE
	f.subpixel_positioning = TextServer.SUBPIXEL_POSITIONING_DISABLED
	f.hinting = TextServer.HINTING_NONE
	f.multichannel_signed_distance_field = false
	lbl.add_theme_font_override("font", f)
	lbl.add_theme_font_size_override("font_size", size)

func _panel_style() -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = C_PANEL
	s.border_color = C_BORDER
	s.set_border_width_all(2)
	s.set_corner_radius_all(8)
	s.shadow_color = Color(0, 0, 0, 0.5)
	s.shadow_size = 8
	return s

func _stats_style() -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = C_PANEL2
	s.border_color = Color(0.18, 0.40, 0.55, 0.6)
	s.set_border_width_all(1)
	s.set_corner_radius_all(5)
	return s

func _style_button(btn : Button, color : Color) -> void:
	var mk := func(mul : float) -> StyleBoxFlat:
		var s := StyleBoxFlat.new()
		s.bg_color = Color(color.r * mul, color.g * mul, color.b * mul)
		s.border_color = color
		s.set_border_width_all(2)
		s.set_corner_radius_all(4)
		return s
	btn.add_theme_stylebox_override("normal", mk.call(0.30))
	btn.add_theme_stylebox_override("hover", mk.call(0.55))
	btn.add_theme_stylebox_override("pressed", mk.call(0.18))
	btn.add_theme_stylebox_override("focus", mk.call(0.55))
	btn.add_theme_color_override("font_color", Color(0.92, 0.97, 1.0))
	btn.add_theme_color_override("font_hover_color", C_WHITE)
	btn.add_theme_color_override("font_focus_color", C_WHITE)
	_apply_pixel_font(btn, 12)

# ── Continue ────────────────────────────────────────────────────────────────

func _compute_stars(correct : int, total : int, deaths : int, enemies_defeated : int, enemies_total : int) -> int:
	var accuracy : float = float(correct) / float(max(total, 1))
	var stars : int = 1
	if accuracy >= 0.9 and deaths <= 1:
		stars = 3
	elif accuracy >= 0.7 and deaths <= 3:
		stars = 2
	# Running past the level's enemies instead of fighting them caps the score —
	# engaging enemies (and their quiz battles) is the point of the level.
	if enemies_total > 0:
		var engagement : float = float(enemies_defeated) / float(enemies_total)
		if engagement < 0.34:
			stars = min(stars, 1)
		elif engagement < 0.67:
			stars = min(stars, 2)
	return stars

func _format_time(seconds : int) -> String:
	return "%d:%02d" % [seconds / 60, seconds % 60]

func _on_continue_pressed():
	if _done:
		return
	_done = true
	continue_pressed.emit()
