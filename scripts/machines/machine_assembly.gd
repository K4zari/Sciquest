extends Node2D
class_name MachineAssembly

## Finale controller for the "Build the Complex Machine" puzzle (KSSR 10.2.3).
##
## Counts the AssemblyStations / PressurePlates whose crystal_ids it requires.
## When every required system is online the great machine animates, the exit
## gate opens (it emits crystal_lit with its own crystal_id, so a CrusherDoor
## with linked_crystal_id = crystal_id reacts via the existing pattern) and the
## level-end Teleport is activated.

@export var required_ids : Array[String] = []
@export var crystal_id : String = "asm_done"
@export var teleport_path : NodePath
@export var label_path : NodePath
## Machine part sprites that start spinning when the machine comes alive.
@export var machine_gears : Array[NodePath] = []
@export var gear_spin_speed : float = 2.0

var _online : Dictionary = {}
var _done : bool = false
var _gears : Array[Node2D] = []
var _label : Label

func _ready() -> void:
	for p in machine_gears:
		var n := get_node_or_null(p)
		if n is Node2D:
			_gears.append(n)
	_label = get_node_or_null(label_path) as Label
	EventBus.crystal_lit.connect(_on_crystal_lit)
	EventBus.crystal_unlit.connect(_on_crystal_unlit)
	_update_label()

func _process(delta : float) -> void:
	if not _done:
		return
	for g in _gears:
		g.rotation += gear_spin_speed * delta

func _id_of(src) -> String:
	if src is Node and "crystal_id" in src:
		return src.crystal_id
	return ""

func _on_crystal_lit(src) -> void:
	if _done:
		return
	var id := _id_of(src)
	if id in required_ids:
		_online[id] = true
		_update_label()
		if _online.size() == required_ids.size():
			_complete()

func _on_crystal_unlit(src) -> void:
	if _done:
		return
	var id := _id_of(src)
	if id in required_ids and _online.has(id):
		_online.erase(id)
		_update_label()

func _update_label() -> void:
	if _label:
		_label.text = tr("SYSTEMS ONLINE") + ": %d / %d" % [_online.size(), required_ids.size()]

func _complete() -> void:
	_done = true
	if _label:
		_label.text = tr("MACHINE ASSEMBLED!")
	AudioManager.play_sfx("crusher")
	EventBus.crystal_lit.emit(self)
	var tp = get_node_or_null(teleport_path)
	if tp == null:
		tp = get_parent().get_node_or_null("Teleport")
	if tp and tp.has_method("activate"):
		tp.activate()
	print("MCP_RESPONSE:" + JSON.stringify({"type": "assembly_complete", "teleport_found": tp != null}))
