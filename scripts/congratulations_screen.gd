extends CanvasLayer
class_name CongratulationsScreen

## Grand finale shown once the player has cleared every topic (all levels except
## the tutorial). A full-screen, high-energy celebration: animated gradient sky,
## drifting twinkles, a bouncing colour-cycling headline, a spinning trophy star,
## continuous confetti rain, and periodic firework bursts — built in the same
## pixel-font menu language as level_complete_screen.gd.

signal continue_pressed

const FONT_PATH := "res://fonts/m6x11 Daniel LInssen.ttf"

# ── Palette (shared language with the menu / level-complete screens) ─────────
const C_WHITE   := Color(1, 1, 1)
const C_OUTLINE := Color(0, 0, 0)
const C_GOLD    := Color(1.00, 0.83, 0.28)
const C_CYAN    := Color(0.40, 0.85, 1.00)
const C_GREEN   := Color(0.42, 1.00, 0.55)
const C_PINK    := Color(1.00, 0.55, 0.72)
const C_PURPLE  := Color(0.74, 0.62, 1.00)
const C_BTN     := Color(0.10, 0.62, 0.92)

# Festive colours reused for confetti, fireworks and the headline shimmer.
const PARTY := [
	Color(0.40, 0.85, 1.00), Color(1.00, 0.83, 0.28), Color(0.42, 1.00, 0.55),
	Color(1.00, 0.55, 0.72), Color(0.74, 0.62, 1.00), Color(1, 1, 1),
]

var _fx : Control                    # screen-space layer for confetti + fireworks
var _continue_button : Button
var _done : bool = false

func _ready():
	layer = 25                       # above the level-complete screen (20)
	_build()
	_animate_in()

# ── Build ────────────────────────────────────────────────────────────────────

func _build() -> void:
	var vp := get_viewport().get_visible_rect().size

	# Animated gradient sky (radial glow over a deep navy base).
	var bg := TextureRect.new()
	bg.texture = _sky_texture()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_STOP   # eats clicks behind the screen
	bg.modulate.a = 0.0
	add_child(bg)
	create_tween().tween_property(bg, "modulate:a", 1.0, 0.5)
	_pulse_modulate(bg, Color(1.18, 1.10, 1.25), Color(0.85, 0.90, 1.05), 2.6)

	_make_twinkles(vp)

	# Spinning, pulsing trophy star above the headline.
	var trophy := _glyph("★", 56, C_GOLD)
	trophy.size = Vector2(vp.x, 70)
	trophy.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	trophy.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	trophy.position = Vector2(0, 18)
	trophy.pivot_offset = Vector2(vp.x * 0.5, 35)
	trophy.scale = Vector2.ZERO
	add_child(trophy)
	_pop(trophy, 0.5, 0.15)
	_spin(trophy, 7.0)
	_pulse_scale(trophy, 1.12, 1.2)

	# Headline glow + colour-cycling title.
	var glow := _ctext(tr("CONGRATULATIONS!"), 33, Color(1.0, 0.7, 0.15, 0.20), vp.x, 96)
	glow.position.y = 99
	var title := _ctext(tr("CONGRATULATIONS!"), 32, C_WHITE, vp.x, 96)
	title.add_theme_color_override("font_outline_color", C_OUTLINE)
	title.add_theme_constant_override("outline_size", 5)
	title.pivot_offset = Vector2(vp.x * 0.5, 18)
	title.scale = Vector2.ZERO
	_pop(title, 0.55, 0.32)
	_rainbow(title)
	_pulse_scale(title, 1.04, 1.4)

	# Subtitles.
	var sub := _ctext(tr("You completed every topic!"), 13, C_CYAN, vp.x, 150)
	sub.modulate.a = 0.0
	create_tween().tween_property(sub, "modulate:a", 1.0, 0.4).set_delay(0.7)

	var champ := _ctext(tr("TRUE SCIENCE CHAMPION!"), 15, C_GOLD, vp.x, 174)
	champ.add_theme_color_override("font_outline_color", C_OUTLINE)
	champ.add_theme_constant_override("outline_size", 3)
	champ.pivot_offset = Vector2(vp.x * 0.5, 11)
	champ.scale = Vector2.ZERO
	_pop(champ, 0.5, 0.9)
	_pulse_scale(champ, 1.05, 1.1)

	# Continue button.
	_continue_button = Button.new()
	_continue_button.text = tr("CONTINUE  ►")
	_continue_button.size = Vector2(170, 28)
	_continue_button.position = Vector2((vp.x - 170) * 0.5, 286)
	_continue_button.pivot_offset = Vector2(85, 14)
	_style_button(_continue_button, C_BTN)
	_continue_button.modulate.a = 0.0
	_continue_button.pressed.connect(_on_continue_pressed)
	add_child(_continue_button)

	# Front layer for confetti + fireworks.
	_fx = Control.new()
	_fx.set_anchors_preset(Control.PRESET_FULL_RECT)
	_fx.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_fx)

# ── Entrance choreography ──────────────────────────────────────────────────

func _animate_in() -> void:
	AudioManager.play_sfx("level_complete")
	AudioManager.play_music("main_menu")
	_flash()

	await get_tree().create_timer(0.15).timeout
	_burst_confetti(46)

	# Kick off the ongoing celebration loops (auto-stop when this node frees).
	_start_confetti_rain()
	_start_fireworks()

	await get_tree().create_timer(1.0).timeout
	var bt := create_tween()
	bt.tween_property(_continue_button, "modulate:a", 1.0, 0.35)
	_continue_button.grab_focus.call_deferred()
	_pulse_scale(_continue_button, 1.06, 0.6)

# ── Continuous celebration loops ───────────────────────────────────────────

func _start_confetti_rain() -> void:
	var timer := Timer.new()
	timer.wait_time = 0.55
	timer.autostart = true
	add_child(timer)
	timer.timeout.connect(func(): _burst_confetti(8))

func _start_fireworks() -> void:
	var timer := Timer.new()
	timer.wait_time = 0.9
	timer.autostart = true
	add_child(timer)
	timer.timeout.connect(_spawn_firework)

func _spawn_firework() -> void:
	var vp := get_viewport().get_visible_rect().size
	var center := Vector2(randf_range(vp.x * 0.15, vp.x * 0.85), randf_range(vp.y * 0.15, vp.y * 0.55))
	var col : Color = PARTY[randi() % PARTY.size()]
	AudioManager.play_sfx("level_complete", -10.0)
	var n := 16
	for i in n:
		var spark := ColorRect.new()
		spark.color = col
		spark.size = Vector2(3, 3)
		spark.pivot_offset = Vector2(1.5, 1.5)
		spark.position = center
		_fx.add_child(spark)
		var ang := TAU * float(i) / float(n) + randf_range(-0.1, 0.1)
		var dist := randf_range(26.0, 52.0)
		var dest := center + Vector2(cos(ang), sin(ang)) * dist
		var dur := randf_range(0.6, 0.9)
		var t := create_tween().set_parallel(true)
		t.tween_property(spark, "position", dest + Vector2(0, 14), dur).set_ease(Tween.EASE_OUT)
		t.tween_property(spark, "modulate:a", 0.0, dur).set_ease(Tween.EASE_IN)
		t.chain().tween_callback(spark.queue_free)

func _burst_confetti(count : int) -> void:
	var vp := get_viewport().get_visible_rect().size
	for i in count:
		var p := ColorRect.new()
		p.color = PARTY[randi() % PARTY.size()]
		p.size = Vector2(randf_range(3, 6), randf_range(4, 8))
		p.pivot_offset = p.size * 0.5
		var sx := randf_range(0, vp.x)
		p.position = Vector2(sx, randf_range(-20, -4))
		p.rotation = randf_range(0, TAU)
		_fx.add_child(p)
		var dur := randf_range(1.6, 3.0)
		var move := create_tween().set_parallel(true)
		move.tween_property(p, "position", Vector2(sx + randf_range(-60, 60), vp.y + 20), dur) \
			.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
		move.tween_property(p, "rotation", p.rotation + randf_range(-12, 12), dur)
		var fade := create_tween()
		fade.tween_interval(dur * 0.6)
		fade.tween_property(p, "modulate:a", 0.0, dur * 0.4)
		fade.tween_callback(p.queue_free)

func _make_twinkles(vp : Vector2) -> void:
	for i in 22:
		var star := _glyph("✦", randi_range(7, 12), PARTY[randi() % PARTY.size()])
		star.position = Vector2(randf_range(8, vp.x - 8), randf_range(8, vp.y - 30))
		star.modulate.a = 0.0
		add_child(star)
		var t := create_tween().set_loops()
		t.tween_interval(randf_range(0.0, 2.5))
		t.tween_property(star, "modulate:a", randf_range(0.35, 0.8), 0.5).set_ease(Tween.EASE_OUT)
		t.tween_property(star, "modulate:a", 0.0, 0.8).set_ease(Tween.EASE_IN)
		t.tween_interval(randf_range(0.5, 2.2))

func _flash() -> void:
	var f := ColorRect.new()
	f.color = Color(1, 1, 1, 0.6)
	f.set_anchors_preset(Control.PRESET_FULL_RECT)
	f.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(f)
	var t := create_tween()
	t.tween_property(f, "color:a", 0.0, 0.5)
	t.tween_callback(f.queue_free)

# ── Animation helpers ──────────────────────────────────────────────────────

func _pop(node : Control, dur : float, delay : float) -> void:
	node.scale = Vector2.ZERO
	var t := create_tween()
	t.tween_interval(delay)
	t.tween_property(node, "scale", Vector2.ONE, dur).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

func _pulse_scale(node : Control, amount : float, period : float) -> void:
	# Delay the looping pulse until every entrance pop-in has finished so the two
	# scale tweens don't fight over the same property.
	await get_tree().create_timer(1.5).timeout
	if not is_instance_valid(node):
		return
	var t := create_tween().set_loops().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	t.tween_property(node, "scale", Vector2(amount, amount), period * 0.5)
	t.tween_property(node, "scale", Vector2.ONE, period * 0.5)

func _pulse_modulate(node : CanvasItem, a : Color, b : Color, period : float) -> void:
	var t := create_tween().set_loops().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	t.tween_property(node, "modulate", a, period * 0.5)
	t.tween_property(node, "modulate", b, period * 0.5)

func _spin(node : Control, period : float) -> void:
	var t := create_tween().set_loops()
	t.tween_property(node, "rotation", TAU, period).from(0.0)

func _rainbow(node : CanvasItem) -> void:
	await get_tree().create_timer(0.9).timeout
	if not is_instance_valid(node):
		return
	var t := create_tween().set_loops().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	for c in [C_GOLD, C_PINK, C_CYAN, C_GREEN, C_PURPLE]:
		t.tween_property(node, "modulate", c, 0.7)
	t.tween_property(node, "modulate", C_GOLD, 0.7)

# ── Label / style helpers ──────────────────────────────────────────────────

## Centered, pixel-font text label spanning `w`, added to the screen.
func _ctext(s : String, fs : int, color : Color, w : float, y : float) -> Label:
	var l := Label.new()
	l.text = s
	l.add_theme_color_override("font_color", color)
	l.size = Vector2(w, fs + 10)
	l.position = Vector2(0, y)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_apply_pixel_font(l, fs)
	add_child(l)
	return l

## Glyph label (★ ✦) — keeps the default font, which carries these symbols.
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

func _sky_texture() -> GradientTexture2D:
	var grad := Gradient.new()
	grad.set_offset(0, 0.0)
	grad.set_offset(1, 1.0)
	grad.set_color(0, Color(0.10, 0.16, 0.34))   # glow centre
	grad.set_color(1, Color(0.02, 0.03, 0.08))   # dark edges
	var tex := GradientTexture2D.new()
	tex.gradient = grad
	tex.fill = GradientTexture2D.FILL_RADIAL
	tex.fill_from = Vector2(0.5, 0.42)
	tex.fill_to = Vector2(1.05, 1.05)
	tex.width = 320
	tex.height = 180
	return tex

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

func _on_continue_pressed():
	if _done:
		return
	_done = true
	continue_pressed.emit()
