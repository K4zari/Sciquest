extends StaticBody2D
class_name CrystalDoor

@export var linked_crystal_id : String = ""
@export var open_offset : Vector2 = Vector2(0, 64)
@export var open_duration : float = 0.8
@export var auto_relock : bool = false

@onready var initial_pos : Vector2 = position
@onready var collider : CollisionShape2D = $CollisionShape2D if has_node("CollisionShape2D") else null

var is_open : bool = false
var _tween : Tween

signal opened
signal closed

func _ready():
	add_to_group("CrystalDoors")
	EventBus.crystal_lit.connect(_on_crystal_lit)
	EventBus.crystal_unlit.connect(_on_crystal_unlit)

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
	if _tween and _tween.is_running():
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(self, "position", initial_pos, open_duration)
	_tween.finished.connect(func (): closed.emit())
