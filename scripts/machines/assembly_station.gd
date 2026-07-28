extends Node2D
class_name AssemblyStation

## One station of the "Build the Complex Machine" finale (KSSR 10.2.3).
##
## A lever (targets = [this]) switches the station on: its part sprites start
## spinning, the station brightens, and it lights its crystal_id so the
## MachineAssembly controller can count it as online. Mirrors wind_turbine.gd's
## lever/crystal contract so existing levers and doors need no changes.

@export var crystal_id : String = ""
@export var spin_speed : float = 3.0
## Sprite spun clockwise while the station runs (optional).
@export var spin_target : NodePath
## Second sprite spun counter-clockwise, for meshed gear pairs (optional).
@export var counter_target : NodePath

const OFF_TINT := Color(0.55, 0.55, 0.6)

var _running : bool = false
var _spin : Node2D
var _counter : Node2D

func _ready() -> void:
	_spin = get_node_or_null(spin_target)
	_counter = get_node_or_null(counter_target)
	modulate = OFF_TINT

func _process(delta : float) -> void:
	if not _running:
		return
	if _spin:
		_spin.rotation += spin_speed * delta
	if _counter:
		_counter.rotation -= spin_speed * delta

func _on_lever_activated() -> void:
	if _running:
		return
	_running = true
	modulate = Color.WHITE
	EventBus.crystal_lit.emit(self)

func _on_lever_deactivated() -> void:
	if not _running:
		return
	_running = false
	modulate = OFF_TINT
	EventBus.crystal_unlit.emit(self)
