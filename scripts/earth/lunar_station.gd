extends Area2D
class_name LunarStation

## A telescope the player operates with E. Instead of a sprite floating above the scope,
## pressing E opens a first-person eyepiece overlay (TelescopeView): the player aims at
## the night sky to find the Moon and watches it cycle through its phases in real time.
## Pressing E again while the Full Moon is centred opens the linked gate through the
## crystal_lit channel. Teaches that the Moon reflects sunlight and shows phases as it
## orbits Earth.

## CrystalMarker (crystal_id = "moon_gate") used to drive the matching CrusherDoor.
@export var emitter : Node2D
## The eyepiece overlay opened on interaction.
@export var telescope_view : CanvasLayer

signal player_nearby(node : Area2D)
signal player_left

var _lit : bool = false

func _ready() -> void:
	add_to_group("Interactables")
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	if telescope_view:
		telescope_view.matched.connect(_on_matched)

func _on_body_entered(body : Node) -> void:
	if body == Globals.player:
		player_nearby.emit(self)

func _on_body_exited(body : Node) -> void:
	if body == Globals.player:
		player_left.emit()

## Called by level.gd when the player presses E while in range. The same key both opens
## the eyepiece and confirms the match once the Full Moon is centred.
func interact() -> void:
	if telescope_view == null:
		return
	if telescope_view.is_open:
		telescope_view.try_confirm()
	else:
		telescope_view.open()

func _on_matched() -> void:
	if _lit:
		return
	_lit = true
	if emitter:
		EventBus.crystal_lit.emit(emitter)
