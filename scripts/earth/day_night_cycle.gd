extends Node2D
class_name DayNightCycle

## Owns the day<->night time-lapse for Zone B. Two ways to drive it:
##
## 1. Auto sunset (auto_drive): as the player walks from Zone A into Zone B the sun
##    gradually sets and day turns to night — fully night by the time they reach the
##    rest shelter. This is position-driven (auto_player_start_x .. auto_player_end_x).
## 2. Rest (TimeShelter.advance): resting brings the daylight back. When day returns,
##    any armed sun-vulnerable enemies (the Zone B/C skeletons) are destroyed by the
##    sunlight.
##
## Sun-vulnerability is only *armed* once the first nightfall happens, so the skeletons
## are NOT burned by the initial daytime while the player is still back in Zone A.
## Teaches that Earth's rotation makes day turn into night, and that sunlight returns
## when a new day begins.

signal transition_started
signal transition_finished(is_day : bool)

@export var is_day : bool = true
@export var transition_time : float = 2.5

@export_group("Auto Sunset")
## When true the cycle drives day->night from the player's x position (Zone A -> Zone B).
@export var auto_drive : bool = false
## Player x where the sun is still fully up (full day).
@export var auto_player_start_x : float = 1000.0
## Player x where night has fully fallen.
@export var auto_player_end_x : float = 1280.0

@export_group("Scene References")
@export var day_sky : CanvasItem
@export var night_sky : CanvasItem
@export var clouds : CanvasItem
@export var sun : Node2D
@export var moon : Node2D
@export var canvas_modulate : CanvasModulate
## CrystalMarker (crystal_id = "earth_day") whose gate opens during the day.
@export var day_emitter : Node2D
## CrystalMarker (crystal_id = "earth_night") whose gate opens at night.
@export var night_emitter : Node2D
## Enemies (Zone B/C skeletons) destroyed by sunlight when day returns after nightfall.
@export var sun_vulnerable : Array[Node] = []

@export_group("Tuning")
@export var day_color : Color = Color(1, 1, 1)
@export var night_color : Color = Color(0.30, 0.36, 0.58)
## How far (px) the Sun/Moon sweep along the sky. Positive x = East (right) to West.
@export var arc_span : Vector2 = Vector2(-260, 40)

var _busy : bool = false
var _sun_home : Vector2
var _moon_home : Vector2
## Set once the world has gone fully dark; gates the sunlight kill so the initial
## daytime in Zone A never burns the skeletons.
var _sun_armed : bool = false
## Once the player has reached night via the auto sunset we stop re-driving from
## position, so resting (which brings day back) isn't immediately undone.
var _night_reached : bool = false
## True after the player rests to bring the day back — auto sunset stays disabled.
var _rested : bool = false

func _ready() -> void:
	if sun:
		_sun_home = sun.position
	if moon:
		_moon_home = moon.position
	_apply_visuals(is_day)
	# Defer the first gate sync so every CrusherDoor has connected to the EventBus.
	call_deferred("_update_gates")

func _process(_delta : float) -> void:
	if not auto_drive or _busy or _night_reached or _rested:
		return
	var player := Globals.player
	if not is_instance_valid(player):
		return
	var span : float = max(1.0, auto_player_end_x - auto_player_start_x)
	var f : float = clampf((player.global_position.x - auto_player_start_x) / span, 0.0, 1.0)
	_apply_phase_factor(f)
	if f >= 0.98:
		_enter_night()

func is_busy() -> bool:
	return _busy

## The first full nightfall: lock in night, open the night gate, and arm the
## sunlight so the next daybreak destroys the skeletons.
func _enter_night() -> void:
	if _night_reached:
		return
	_night_reached = true
	is_day = false
	_sun_armed = true
	_apply_visuals(false)
	_update_gates()
	transition_finished.emit(false)

## Rest at the shelter: always brings the daylight back (and, once night has fallen,
## burns the sun-vulnerable night creatures).
func advance() -> void:
	if _busy:
		return
	_busy = true
	transition_started.emit()
	var to_day : bool = true

	var tw := create_tween().set_parallel(true).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	if day_sky:
		tw.tween_property(day_sky, "modulate:a", 1.0 if to_day else 0.0, transition_time)
	if night_sky:
		tw.tween_property(night_sky, "modulate:a", 0.0 if to_day else 1.0, transition_time)
	if canvas_modulate:
		tw.tween_property(canvas_modulate, "color", day_color if to_day else night_color, transition_time)
	# The body that owns the incoming phase sweeps home and fades in; the outgoing one
	# sets over the arc and fades out.
	if sun:
		tw.tween_property(sun, "position", _sun_home if to_day else _sun_home + arc_span, transition_time)
		tw.tween_property(sun, "modulate:a", 1.0 if to_day else 0.0, transition_time)
	if moon:
		tw.tween_property(moon, "position", _moon_home if not to_day else _moon_home + arc_span, transition_time)
		tw.tween_property(moon, "modulate:a", 0.0 if to_day else 1.0, transition_time)
	await tw.finished

	# Daylight returns: stop the auto sunset and burn the night creatures.
	is_day = true
	_rested = true
	_burn_sun_vulnerable()
	_update_gates()
	_busy = false
	transition_finished.emit(true)

## Continuous day(0) -> night(1) blend used by the auto sunset.
func _apply_phase_factor(f : float) -> void:
	if day_sky:
		day_sky.modulate.a = 1.0 - f
	if night_sky:
		night_sky.modulate.a = f
	if canvas_modulate:
		canvas_modulate.color = day_color.lerp(night_color, f)
	if sun:
		sun.position = _sun_home.lerp(_sun_home + arc_span, f)
		sun.modulate.a = 1.0 - f
	if moon:
		moon.position = (_moon_home + arc_span).lerp(_moon_home, f)
		moon.modulate.a = f

func _apply_visuals(day : bool) -> void:
	_apply_phase_factor(0.0 if day else 1.0)

func _burn_sun_vulnerable() -> void:
	if not _sun_armed:
		return
	for enemy in sun_vulnerable:
		if is_instance_valid(enemy) and enemy.has_method("die_from_sun"):
			enemy.die_from_sun()

func _update_gates() -> void:
	# Open the gate for the current phase, relock the other (gates use auto_relock).
	if is_day:
		if day_emitter:
			EventBus.crystal_lit.emit(day_emitter)
		if night_emitter:
			EventBus.crystal_unlit.emit(night_emitter)
	else:
		if night_emitter:
			EventBus.crystal_lit.emit(night_emitter)
		if day_emitter:
			EventBus.crystal_unlit.emit(day_emitter)
