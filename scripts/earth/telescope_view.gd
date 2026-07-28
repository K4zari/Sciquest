extends CanvasLayer
class_name TelescopeView

## A first-person telescope eyepiece. When the player operates the LunarStation this
## overlay opens: a black screen with a circular cut-out (the eyepiece) onto the night
## sky. The player pans with the arrow keys to FIND the Moon, then WATCHES it cycle
## through its phases in real time. When the Full Moon is centred in the cross-hair the
## player presses E to confirm — teaching that the Moon reflects sunlight and shows
## different phases as it orbits Earth.

signal matched   ## Full Moon centred & confirmed — opens the linked gate.
signal closed

const PHASE_NAMES := [
	"New Moon", "Waxing Crescent", "First Quarter", "Waxing Gibbous", "Full Moon",
]
const PHASE_COUNT := 5
const FULL_PHASE := 4

@export var pan_speed : float = 220.0
@export var pan_limit : float = 170.0
@export var phase_interval : float = 1.4
@export var find_radius : float = 50.0
## Pause (seconds) after the player confirms the Full Moon, before the eyepiece closes
## and the gate opens — a satisfying "locked in" beat.
@export var lock_delay : float = 1.0

var is_open : bool = false

var _built : bool = false
var _pan : Vector2 = Vector2.ZERO
var _moon_sky : Vector2 = Vector2.ZERO
var _phase : int = 0
var _phase_t : float = 0.0
var _found : bool = false
var _was_found : bool = false
var _hint_t : float = 0.0
var _idle_t : float = 0.0
var _locking : bool = false

## How long the player can search without finding the Moon before we nudge them.
const IDLE_NUDGE_TIME : float = 4.0

var _bg : ColorRect
var _stars : Sprite2D
var _moon : Sprite2D
var _vignette : ColorRect
var _cross_h : ColorRect
var _cross_v : ColorRect
var _phase_label : Label
var _hint_label : Label

const VIGNETTE_SHADER := """
shader_type canvas_item;
uniform float radius : hint_range(0.0, 1.0) = 0.34;
uniform float softness : hint_range(0.0, 0.5) = 0.03;
void fragment() {
	vec2 res = 1.0 / SCREEN_PIXEL_SIZE;
	float aspect = res.x / res.y;
	vec2 uv = UV - vec2(0.5);
	uv.x *= aspect;
	float d = length(uv);
	float a = smoothstep(radius, radius + softness, d);
	COLOR = vec4(0.02, 0.02, 0.05, a);
}
"""

func _ready() -> void:
	layer = 50
	visible = false
	set_process(false)
	_build()

func _build() -> void:
	if _built:
		return
	_built = true
	var size : Vector2 = get_viewport().get_visible_rect().size

	_bg = ColorRect.new()
	_bg.color = Color(0.03, 0.04, 0.10)
	_bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	_bg.z_index = 0
	_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_bg)

	_stars = Sprite2D.new()
	_stars.texture = preload("res://graphics/topic_9_earth/stars.png")
	_stars.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_stars.centered = true
	_stars.scale = Vector2(2.0, 2.0)
	_stars.z_index = 1
	add_child(_stars)

	_moon = Sprite2D.new()
	_moon.texture = preload("res://graphics/topic_9_earth/moon_phases.png")
	_moon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_moon.hframes = PHASE_COUNT
	_moon.centered = true
	_moon.scale = Vector2(1.4, 1.4)
	_moon.z_index = 2
	add_child(_moon)

	_vignette = ColorRect.new()
	_vignette.set_anchors_preset(Control.PRESET_FULL_RECT)
	_vignette.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_vignette.z_index = 3
	var sh := Shader.new()
	sh.code = VIGNETTE_SHADER
	var mat := ShaderMaterial.new()
	mat.shader = sh
	_vignette.material = mat
	add_child(_vignette)

	_cross_h = ColorRect.new()
	_cross_h.color = Color(1, 1, 1, 0.7)
	_cross_h.size = Vector2(18, 2)
	_cross_h.z_index = 4
	_cross_h.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_cross_h)

	_cross_v = ColorRect.new()
	_cross_v.color = Color(1, 1, 1, 0.7)
	_cross_v.size = Vector2(2, 18)
	_cross_v.z_index = 4
	_cross_v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_cross_v)

	var title := Label.new()
	title.text = "TELESCOPE   -   Move / Stick: search the sky    E / (B): confirm Full Moon    Esc / (Y): leave"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.z_index = 5
	title.position = Vector2(0, 14)
	title.size = Vector2(size.x, 20)
	title.add_theme_color_override("font_color", Color(0.85, 0.9, 1.0))
	add_child(title)

	_phase_label = Label.new()
	_phase_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_phase_label.z_index = 5
	_phase_label.position = Vector2(0, size.y - 40)
	_phase_label.size = Vector2(size.x, 20)
	_phase_label.add_theme_color_override("font_color", Color(1, 1, 1))
	add_child(_phase_label)

	_hint_label = Label.new()
	_hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_hint_label.z_index = 5
	_hint_label.position = Vector2(0, size.y - 64)
	_hint_label.size = Vector2(size.x, 20)
	_hint_label.add_theme_color_override("font_color", Color(1.0, 0.8, 0.3))
	_hint_label.modulate.a = 0.0
	add_child(_hint_label)

func open() -> void:
	if is_open:
		return
	is_open = true
	visible = true
	_locking = false
	_phase_label.add_theme_color_override("font_color", Color(1, 1, 1))
	# Start the Moon off to a random side so the player must aim to find it.
	var ang := randf() * TAU
	_moon_sky = Vector2(cos(ang), sin(ang)) * (pan_limit * 0.7)
	_pan = Vector2.ZERO
	_phase = randi() % PHASE_COUNT
	_phase_t = 0.0
	_hint_t = 0.0
	_idle_t = 0.0
	_found = false
	_was_found = false
	# Tell the player exactly what to do the moment the eyepiece opens.
	_flash_hint("Pan with the ARROW KEYS to find the Moon")
	if Globals.player:
		Globals.player.frozen = true
		Globals.player.velocity = Vector2.ZERO
		if Globals.player.state_machine:
			Globals.player.state_machine.transition("IdleState")
	set_process(true)
	_update_view()

func close() -> void:
	if not is_open:
		return
	is_open = false
	visible = false
	set_process(false)
	if Globals.player:
		Globals.player.frozen = false
	closed.emit()

## Leave the eyepiece without matching. Esc on keyboard, or the Y button on a
## controller — kept separate from B, which confirms the Full Moon (interact).
func _input(event : InputEvent) -> void:
	if not is_open or _locking:
		return
	var leave := false
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
		leave = true
	elif event is InputEventJoypadButton and event.pressed and event.button_index == JOY_BUTTON_Y:
		leave = true
	if leave:
		close()
		get_viewport().set_input_as_handled()

## Called by LunarStation when the player presses E while the eyepiece is open.
func try_confirm() -> void:
	if not is_open or _locking:
		return
	if _found and _phase == FULL_PHASE:
		_lock_in()
	elif not _found:
		_flash_hint("Aim at the Moon!")
	else:
		_flash_hint("Wait for the Full Moon...")

## Hold on the Full Moon for a beat (frozen, highlighted) before opening the gate.
func _lock_in() -> void:
	_locking = true
	_cross_h.color = Color(0.4, 1.0, 0.4, 0.95)
	_cross_v.color = Color(0.4, 1.0, 0.4, 0.95)
	_phase_label.add_theme_color_override("font_color", Color(0.4, 1.0, 0.4))
	_phase_label.text = "Full Moon - locked in!"
	await get_tree().create_timer(lock_delay).timeout
	matched.emit()
	close()

func _process(delta : float) -> void:
	if not is_open or _locking:
		return

	var dir := Vector2(
		Input.get_axis("ui_left", "ui_right"),
		Input.get_axis("ui_up", "ui_down")
	)
	_pan += dir * pan_speed * delta
	_pan.x = clampf(_pan.x, -pan_limit, pan_limit)
	_pan.y = clampf(_pan.y, -pan_limit, pan_limit)

	_phase_t += delta
	if _phase_t >= phase_interval:
		_phase_t -= phase_interval
		_phase = (_phase + 1) % PHASE_COUNT

	if _hint_t > 0.0:
		_hint_t -= delta
		if _hint_t <= 0.0:
			_hint_label.modulate.a = 0.0

	_found = (_pan - _moon_sky).length() < find_radius

	if _found and not _was_found:
		# Just centred the Moon — explain the next step (wait for the Full phase).
		_flash_hint("Moon found! Wait until it is FULL, then press E / (B)")
		_idle_t = 0.0
	elif not _found:
		# Still searching — nudge the player again if they've been lost a while.
		_idle_t += delta
		if _idle_t >= IDLE_NUDGE_TIME:
			_idle_t = 0.0
			_flash_hint("Keep panning - the Moon is somewhere in the sky")
	_was_found = _found

	_update_view()

func _update_view() -> void:
	var center : Vector2 = get_viewport().get_visible_rect().size * 0.5
	_stars.position = center - _pan * 0.3
	_moon.position = center + (_moon_sky - _pan)
	_moon.frame = _phase

	_cross_h.position = center - _cross_h.size * 0.5
	_cross_v.position = center - _cross_v.size * 0.5
	var lit : bool = _found and _phase == FULL_PHASE
	var cross_color : Color = Color(0.4, 1.0, 0.4, 0.95) if lit else Color(1, 1, 1, 0.7)
	_cross_h.color = cross_color
	_cross_v.color = cross_color

	var status : String = PHASE_NAMES[_phase]
	if _found:
		status += "  (centred)"
	else:
		status += "  -  aim to find the Moon"
	_phase_label.text = status

func _flash_hint(text : String) -> void:
	_hint_label.text = text
	_hint_label.modulate.a = 1.0
	_hint_t = 1.5
