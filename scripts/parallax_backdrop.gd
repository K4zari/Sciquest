extends ParallaxBackground
## Reusable scrolling parallax backdrop.
##
## Generalises the inline builder in main_menu.gd (`_build_parallax`) so any screen
## can drop in a themed, depth-layered, auto-drifting background and crossfade it.
##
## Layout: an opaque dark base (never faded) sits behind a stack of ParallaxLayers.
## Far layers barely move, near layers move most — same motion-scale curve the main
## menu uses. fade_in()/fade_out() tween only the parallax layers, so fading out
## reveals the dark base underneath (a clean fade-to-dark).

var _layers : Array[ParallaxLayer] = []
var _base : ColorRect = null
var _drift := 8.0                     # px/sec leftward scroll
var _ping_pong := false               # oscillate instead of infinite scroll
var _pp_amplitude := 48.0
var _pp_speed := 0.5
var _pp_t := 0.0
var _fade_tween : Tween = null

func _ready() -> void:
	if layer == 0:
		layer = -1                    # render behind the host Control's UI by default

# ── Dark base fill ─────────────────────────────────────────────────────────────

## Opaque fill drawn behind every parallax layer; stays put when the layers fade.
func set_base_color(c: Color, vp: Vector2) -> void:
	if _base == null:
		_base = ColorRect.new()
		_base.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(_base)
		move_child(_base, 0)          # first child → drawn furthest back
	_base.color = c
	_base.position = Vector2.ZERO
	_base.size = vp

# ── Layers ─────────────────────────────────────────────────────────────────────

func clear_layers() -> void:
	for l in _layers:
		l.queue_free()
	_layers.clear()

## Rebuild the parallax stack from `textures` (back-to-front). `tex_w` feeds the
## seamless horizontal mirror; sprites are framed against the viewport bottom using
## `tex_h`. `tex_scale` uniformly scales the source art — used to normalise sets of
## differing source heights to a common on-screen framing. Layers start invisible —
## call fade_in() to reveal.
func set_layers(textures: Array, tex_w: float, tex_h: float, vp: Vector2, drift := 8.0, tex_scale := 1.0) -> void:
	clear_layers()
	_drift = drift
	_pp_t = 0.0
	scroll_offset.x = 0.0
	var y_off := vp.y - tex_h * tex_scale
	var n := textures.size()
	for i in n:
		var tex := textures[i] as Texture2D
		if tex == null:
			continue
		var pl := ParallaxLayer.new()
		# Far layers (sky) barely move; near layers (foreground) move most.
		var scl := 0.06 + float(i) / float(max(n - 1, 1)) * 0.74
		pl.motion_scale = Vector2(scl, 0)
		pl.motion_mirroring = Vector2(tex_w * tex_scale, 0)
		pl.modulate.a = 0.0           # hidden until faded in
		add_child(pl)

		var spr := Sprite2D.new()
		spr.texture = tex
		spr.centered = false
		spr.scale = Vector2(tex_scale, tex_scale)
		spr.position = Vector2(0, y_off)
		pl.add_child(spr)
		_layers.append(pl)

func has_layers() -> bool:
	return not _layers.is_empty()

func set_ping_pong(enabled: bool) -> void:
	_ping_pong = enabled

# ── Drift ──────────────────────────────────────────────────────────────────────

func _process(delta: float) -> void:
	if _layers.is_empty():
		return
	if _ping_pong:
		_pp_t += delta * _pp_speed
		scroll_offset.x = sin(_pp_t) * _pp_amplitude
	else:
		scroll_offset.x -= delta * _drift

# ── Crossfade ──────────────────────────────────────────────────────────────────

func fade_in(dur := 0.18) -> void:
	_fade_to(1.0, dur)

func fade_out(dur := 0.18) -> void:
	_fade_to(0.0, dur)

func _fade_to(target_a: float, dur: float) -> void:
	if _fade_tween != null and _fade_tween.is_valid():
		_fade_tween.kill()
	if _layers.is_empty():
		return
	_fade_tween = create_tween().set_parallel(true)
	for l in _layers:
		_fade_tween.tween_property(l, "modulate:a", target_a, dur)
