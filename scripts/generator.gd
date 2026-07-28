extends Area2D
class_name Generator

@export var accepted_source : FuelOrb.Source = FuelOrb.Source.SOLAR
@export var crystal_id : String = ""
@export var label_text : String = ""

@onready var sprite : Sprite2D = $Sprite2D if has_node("Sprite2D") else null
@onready var label : Label = $Label if has_node("Label") else null
@onready var prompt : Label = $Prompt if has_node("Prompt") else null

var powered : bool = false

signal player_nearby(gen : Area2D)
signal player_left
signal generator_powered

func _ready() -> void:
	add_to_group("Generators")
	add_to_group("Interactables")
	if sprite:
		sprite.frame = clamp(int(accepted_source), 0, 2)
	if label:
		label.text = label_text if label_text != "" else _accepted_label()
	if prompt:
		prompt.hide()
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _accepted_label() -> String:
	match accepted_source:
		FuelOrb.Source.SOLAR: return "Solar Cell"
		FuelOrb.Source.WATER: return "Water Turbine"
		FuelOrb.Source.WIND: return "Wind Generator"
		FuelOrb.Source.COAL: return "Combustion Engine"
		FuelOrb.Source.BIOMASS: return "Biomass Burner"
	return ""

func display_name() -> String:
	return label_text if label_text != "" else _accepted_label()

func _on_body_entered(body : Node2D) -> void:
	if body != Globals.player:
		return
	player_nearby.emit(self)
	if prompt and not powered:
		prompt.show()

func _on_body_exited(body : Node2D) -> void:
	if body != Globals.player:
		return
	player_left.emit()
	if prompt:
		prompt.hide()

## Pressing E opens the energy inventory popup, which calls try_energy() back.
func interact() -> void:
	if powered:
		return
	EventBus.energy_select_requested.emit(self)

## Called by the inventory UI when the player picks an orb to insert.
## Returns true if accepted (UI should close), false if rejected (UI stays open).
func try_energy(source : int) -> bool:
	if powered:
		return true
	if source == int(accepted_source):
		_accept(source)
		return true
	_reject()
	return false

func _accept(source : int) -> void:
	powered = true
	AudioManager.play_sfx("generator_power")
	Globals.remove_energy(source)
	EventBus.energy_consumed.emit(source)
	if sprite:
		var t := create_tween()
		t.tween_property(sprite, "modulate", Color(1.6, 1.6, 0.6), 0.15)
		t.tween_property(sprite, "modulate", Color(1.2, 1.2, 1.0), 0.3)
	if prompt:
		prompt.hide()
	generator_powered.emit()
	EventBus.crystal_lit.emit(self)

func _reject() -> void:
	if sprite:
		var t := create_tween()
		t.tween_property(sprite, "modulate", Color(1.8, 0.3, 0.3), 0.08)
		t.tween_property(sprite, "modulate", Color.WHITE, 0.25)
