extends Node
class_name CrusherPattern

@export var crusher_a : NodePath
@export var crusher_b : NodePath
@export var crusher_c : NodePath
@export var start_delay : float = 0.5
@export var rest_between_cycles : float = 0.4

var _a : Crusher
var _b : Crusher
var _c : Crusher
var _running : bool = false

func _ready():
	_a = get_node_or_null(crusher_a)
	_b = get_node_or_null(crusher_b)
	_c = get_node_or_null(crusher_c)
	if _a == null or _b == null or _c == null:
		push_warning("CrusherPattern: missing crusher references")
		return
	await get_tree().process_frame
	if start_delay > 0.0:
		await get_tree().create_timer(start_delay).timeout
	_running = true
	_run_pattern()

func _exit_tree():
	_running = false

func _run_pattern():
	while _running and is_inside_tree():
		if not _all_valid():
			return
		_a.crush()
		_c.crush()
		await _a.lift_started
		if not _all_valid():
			return
		_b.crush()
		await _b.lift_finished
		if rest_between_cycles > 0.0:
			await get_tree().create_timer(rest_between_cycles).timeout

func _all_valid() -> bool:
	return is_instance_valid(_a) and is_instance_valid(_b) and is_instance_valid(_c)
