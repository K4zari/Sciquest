extends Area2D
class_name FuelOrb

enum Source { SOLAR, WATER, WIND, COAL, BIOMASS }

@export var source : Source = Source.SOLAR
@export var label_text : String = ""

const CARRY_OFFSET := Vector2(0, -28)

@onready var sprite : Sprite2D = $Sprite2D if has_node("Sprite2D") else null
@onready var label : Label = $Label if has_node("Label") else null

var carried : bool = false
var _spawn_pos : Vector2
var _hover_tween : Tween

func _ready() -> void:
	add_to_group("FuelOrbs")
	_spawn_pos = global_position
	if sprite:
		sprite.frame = int(source)
	if label:
		label.text = label_text if label_text != "" else source_name()
	body_entered.connect(_on_body_entered)
	_start_hover()

func _physics_process(_delta : float) -> void:
	if carried and Globals.player:
		global_position = Globals.player.global_position + CARRY_OFFSET

func _unhandled_input(event : InputEvent) -> void:
	if not carried:
		return
	if event is InputEventKey and event.is_pressed() and not event.is_echo() and event.keycode == KEY_Q:
		drop()
		get_viewport().set_input_as_handled()

func drop() -> void:
	if not carried:
		return
	var drop_pos : Vector2 = global_position
	if Globals.player:
		drop_pos = Globals.player.global_position
	carried = false
	global_position = drop_pos
	monitoring = true
	_start_hover()

func source_name() -> String:
	match source:
		Source.SOLAR: return "Solar"
		Source.WATER: return "Water"
		Source.WIND: return "Wind"
		Source.COAL: return "Coal"
		Source.BIOMASS: return "Biomass"
	return ""

func _on_body_entered(body : Node2D) -> void:
	if carried:
		return
	if body != Globals.player:
		return
	for orb in get_tree().get_nodes_in_group("FuelOrbs"):
		if orb != self and orb.carried:
			return
	carried = true
	monitoring = false
	_stop_hover()

func _start_hover() -> void:
	if not sprite:
		return
	_hover_tween = create_tween().set_loops().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	_hover_tween.tween_property(sprite, "position:y", sprite.position.y - 3.0, 1.0)
	_hover_tween.tween_property(sprite, "position:y", sprite.position.y, 1.0)

func _stop_hover() -> void:
	if _hover_tween and _hover_tween.is_valid():
		_hover_tween.kill()

func pop_back(drop_pos : Vector2) -> void:
	carried = false
	global_position = drop_pos
	monitoring = true
	if sprite:
		var t := create_tween()
		t.tween_property(sprite, "modulate", Color(1.8, 0.3, 0.3), 0.08)
		t.tween_property(sprite, "modulate", Color.WHITE, 0.25)
	_start_hover()

func consume() -> void:
	carried = false
	monitoring = false
	visible = false
	_stop_hover()
	set_physics_process(false)
