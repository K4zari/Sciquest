extends Area2D
class_name TimeShelter

## A rest hut/booth the player enters to "wait out the time". Pressing E inside (the
## level's interact convention calls interact()) freezes the player and triggers the
## DayNightCycle time-lapse; the player is released once the sky finishes changing.
## Teaches that as time passes (Earth keeps rotating), day turns into night.

## The DayNightCycle controller (typed as Node so the reference resolves even before
## the editor has registered the global class; methods are called dynamically).
@export var cycle : Node
## Optional Label/sprite faded in while resting (e.g. a "Resting…" tag).
@export var rest_label : CanvasItem

signal player_nearby(node : Area2D)
signal player_left

var _resting : bool = false

func _ready() -> void:
	add_to_group("Interactables")
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	if rest_label:
		rest_label.modulate.a = 0.0

func _on_body_entered(body : Node) -> void:
	if body == Globals.player:
		player_nearby.emit(self)

func _on_body_exited(body : Node) -> void:
	if body == Globals.player:
		player_left.emit()

## Called by level.gd when the player presses E while in range.
func interact() -> void:
	if _resting or cycle == null or cycle.is_busy():
		return
	_resting = true
	var player := Globals.player
	if player:
		player.frozen = true
		player.velocity = Vector2.ZERO
		if player.state_machine:
			player.state_machine.transition("IdleState")
	_fade_label(true)
	if not cycle.transition_finished.is_connected(_on_transition_finished):
		cycle.transition_finished.connect(_on_transition_finished)
	cycle.advance()

func _on_transition_finished(_is_day : bool) -> void:
	_fade_label(false)
	if Globals.player:
		Globals.player.frozen = false
	_resting = false

func _fade_label(show_it : bool) -> void:
	if not rest_label:
		return
	var tw := create_tween()
	tw.tween_property(rest_label, "modulate:a", 1.0 if show_it else 0.0, 0.2)
