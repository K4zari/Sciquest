@tool
extends Area2D
class_name FuelOrb

enum Source { SOLAR, WATER, WIND, COAL, BIOMASS }

@export var source : Source = Source.SOLAR:
	set(value):
		source = value
		_update_appearance()
@export var label_text : String = "":
	set(value):
		label_text = value
		_update_appearance()

@onready var sprite : Sprite2D = $Sprite2D if has_node("Sprite2D") else null
@onready var label : Label = $Label if has_node("Label") else null

var _collected : bool = false
var _hover_tween : Tween

signal player_nearby(orb : Area2D)
signal player_left

func _ready() -> void:
	_update_appearance()
	if Engine.is_editor_hint():
		return
	add_to_group("FuelOrbs")
	add_to_group("Interactables")
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	_start_hover()
	# Orbs spawned at runtime (from chests) miss the level's one-time interactable
	# scan, so announce ourselves to get player_nearby/player_left wired up.
	EventBus.interactable_spawned.emit(self)

## Keeps the sprite frame and label in sync with `source`, both at runtime and
## live in the editor (this is a @tool script). Uses get_node_or_null because
## the setters can fire during scene load before @onready vars resolve.
func _update_appearance() -> void:
	var spr := get_node_or_null("Sprite2D") as Sprite2D
	if spr:
		spr.frame = int(source)
	var lbl := get_node_or_null("Label") as Label
	if lbl:
		lbl.text = label_text if label_text != "" else source_name()

func source_name() -> String:
	match source:
		Source.SOLAR: return "Solar"
		Source.WATER: return "Water"
		Source.WIND: return "Wind"
		Source.COAL: return "Coal"
		Source.BIOMASS: return "Biomass"
	return ""

func _on_body_entered(body : Node2D) -> void:
	if _collected:
		return
	if body != Globals.player:
		return
	player_nearby.emit(self)

func _on_body_exited(body : Node2D) -> void:
	if body != Globals.player:
		return
	player_left.emit()

## Called by the level when the player presses E while in range.
## Adds the orb to the energy inventory and removes it from the world.
func interact() -> void:
	if _collected:
		return
	_collected = true
	monitoring = false
	AudioManager.play_sfx("orb_pickup")
	player_left.emit()
	Globals.add_energy(int(source))
	EventBus.energy_collected.emit(int(source))
	_collect_anim()

func _collect_anim() -> void:
	_stop_hover()
	if not sprite:
		queue_free()
		return
	var t := create_tween().set_parallel(true)
	t.tween_property(sprite, "position:y", sprite.position.y - 24.0, 0.35)
	t.tween_property(sprite, "scale", sprite.scale * 0.2, 0.35)
	t.tween_property(sprite, "modulate", Color(1, 1, 1, 0), 0.35)
	t.chain().tween_callback(queue_free)

func _start_hover() -> void:
	if not sprite:
		return
	_hover_tween = create_tween().set_loops().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	_hover_tween.tween_property(sprite, "position:y", sprite.position.y - 3.0, 1.0)
	_hover_tween.tween_property(sprite, "position:y", sprite.position.y, 1.0)

func _stop_hover() -> void:
	if _hover_tween and _hover_tween.is_valid():
		_hover_tween.kill()
