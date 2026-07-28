extends StaticBody2D
class_name CrystalDoor

@export var linked_crystal_id : String = ""
@export var open_offset : Vector2 = Vector2(0, 64)
@export var open_duration : float = 0.8
@export var auto_relock : bool = false
## Seals the gap above the door with an invisible wall while it's closed, so the
## player can't simply jump over the door and skip the light puzzle. Cleared the
## moment the crystal lights and the door opens.
@export var block_overhead : bool = true
@export var overhead_height : float = 200.0

@onready var initial_pos : Vector2 = position
@onready var collider : CollisionShape2D = $CollisionShape2D if has_node("CollisionShape2D") else null

var is_open : bool = false
var _tween : Tween
var _overhead : CollisionShape2D

signal opened
signal closed

func _ready():
	add_to_group("CrystalDoors")
	_build_overhead_barrier()
	EventBus.crystal_lit.connect(_on_crystal_lit)
	EventBus.crystal_unlit.connect(_on_crystal_unlit)

## Adds an invisible wall stacked directly above the door, tall enough that the
## player can't clear it with a jump. It's its own StaticBody2D tagged as a
## "TransparentMaterial" so light beams pass straight through (exactly as they did
## when this space was empty) — only the player is physically blocked.
func _build_overhead_barrier() -> void:
	if not block_overhead or collider == null or not (collider.shape is RectangleShape2D):
		return
	var door_size : Vector2 = (collider.shape as RectangleShape2D).size
	var body := StaticBody2D.new()
	body.add_to_group("TransparentMaterials")
	# Sit it on top of the door collider: half the door up, then half the barrier up.
	body.position = collider.position + Vector2(0, -(door_size.y * 0.5 + overhead_height * 0.5))
	var rect := RectangleShape2D.new()
	rect.size = Vector2(door_size.x, overhead_height)
	_overhead = CollisionShape2D.new()
	_overhead.shape = rect
	body.add_child(_overhead)
	add_child(body)

func _on_crystal_lit(crystal):
	if linked_crystal_id == "" or (crystal is Node and "crystal_id" in crystal and crystal.crystal_id == linked_crystal_id):
		open()

func _on_crystal_unlit(crystal):
	if linked_crystal_id == "" or (crystal is Node and "crystal_id" in crystal and crystal.crystal_id == linked_crystal_id):
		close()

func open() -> void:
	if is_open:
		return
	is_open = true
	if _tween and _tween.is_running():
		_tween.kill()
	if _overhead:
		_overhead.set_deferred("disabled", true)
	_tween = create_tween()
	_tween.tween_property(self, "position", initial_pos + open_offset, open_duration)
	_tween.finished.connect(func ():
		if collider:
			collider.set_deferred("disabled", true)
		opened.emit())

func close() -> void:
	if not is_open:
		return
	is_open = false
	if collider:
		collider.set_deferred("disabled", false)
	if _overhead:
		_overhead.set_deferred("disabled", false)
	if _tween and _tween.is_running():
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(self, "position", initial_pos, open_duration)
	_tween.finished.connect(func (): closed.emit())
