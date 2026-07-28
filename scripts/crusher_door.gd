extends AnimatableBody2D
class_name CrusherDoor

## A portcullis-style gate built from the crusher sprites. It stays down
## (blocking the passage) until its linked puzzle crystal is lit, then retracts
## straight up to open. Reuses the crusher spritesheet so it reads as a heavy
## industrial press lifting out of the way.

@export var linked_crystal_id : String = ""
## Height in tiles. Sized so the door spans floor -> ceiling and cannot be jumped over.
@export var height : int = 15
@export_enum("Forest", "Cave", "Grassland", "OakWood", "Castle") var environment := 4
@export var open_duration : float = 0.7
## When true the door drops back down if the linked crystal is unlit again.
@export var auto_relock : bool = false
## If > 0, the door OPENS by sinking DOWN this many tiles (leaving a low wall the
## player can jump over / hang onto) instead of retracting fully upward.
@export var open_drop : int = 0

@onready var body : Node2D = $Body
@onready var head : Sprite2D = $Body/Head
@onready var body_segment : Sprite2D = $Body/BodySegment
@onready var collision_shape : CollisionShape2D = $CollisionShape2D

var initial_pos : float
var is_open : bool = false
var _tween : Tween

signal opened
signal closed

func _ready() -> void:
	add_to_group("CrusherDoors")
	head.region_rect.position.x = environment * 3 * Globals.TILE_SIZE
	body_segment.region_rect.position.x = environment * 3 * Globals.TILE_SIZE
	initial_pos = position.y
	_construct()
	EventBus.crystal_lit.connect(_on_crystal_lit)
	EventBus.crystal_unlit.connect(_on_crystal_unlit)

## Build the column upward from the head and size the collider to match.
## Origin (y = 0) is the bottom of the door, so it sits on the floor.
func _construct() -> void:
	for i in height - 1:
		var seg : Sprite2D = body_segment.duplicate()
		seg.position.y = -Globals.TILE_SIZE * (2 + i)
		body.add_child(seg)
	collision_shape.shape.size.y = Globals.TILE_SIZE * height
	collision_shape.position.y = -Globals.TILE_SIZE * height * 0.5

func _matches(crystal) -> bool:
	return linked_crystal_id == "" or (crystal is Node and "crystal_id" in crystal and crystal.crystal_id == linked_crystal_id)

func _on_crystal_lit(crystal) -> void:
	if _matches(crystal):
		open()

func _on_crystal_unlit(crystal) -> void:
	if auto_relock and _matches(crystal):
		close()

func open() -> void:
	if is_open:
		return
	is_open = true
	AudioManager.play_sfx("gate_open")
	if _tween and _tween.is_running():
		_tween.kill()
	_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	# open_drop > 0 sinks the wall downward (leaving a low ledge); otherwise the door
	# retracts fully upward out of the way.
	var target_y : float = initial_pos + Globals.TILE_SIZE * open_drop if open_drop > 0 else initial_pos - Globals.TILE_SIZE * height
	_tween.tween_property(self, "position:y", target_y, open_duration)
	_tween.finished.connect(func (): opened.emit())

func close() -> void:
	if not is_open:
		return
	is_open = false
	AudioManager.play_sfx("gate_open")
	if _tween and _tween.is_running():
		_tween.kill()
	_tween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_EXPO)
	_tween.tween_property(self, "position:y", initial_pos, open_duration)
	_tween.finished.connect(func (): closed.emit())
