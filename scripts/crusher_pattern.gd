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
var _a_lifted : bool = false
var _c_lifted : bool = false

func _ready():
	_a = get_node_or_null(crusher_a)
	_b = get_node_or_null(crusher_b)
	_c = get_node_or_null(crusher_c)
	if _a == null or _b == null or _c == null:
		push_warning("CrusherPattern: missing crusher references")
		return
	_a.lift_started.connect(func(): _a_lifted = true)
	_c.lift_started.connect(func(): _c_lifted = true)
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
		_a_lifted = false
		_c_lifted = false
		_a.crush()
		_c.crush()
		AudioManager.play_sfx("crusher")
		while _running and not (_a_lifted and _c_lifted):
			await get_tree().process_frame
		if not _all_valid():
			return
		_b.crush()
		AudioManager.play_sfx("crusher")
		await _b.lift_finished
		if rest_between_cycles > 0.0:
			await get_tree().create_timer(rest_between_cycles).timeout

func _all_valid() -> bool:
	return is_instance_valid(_a) and is_instance_valid(_b) and is_instance_valid(_c)
