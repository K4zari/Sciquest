@tool
extends Node2D
class_name Platform

@export var tile_type : TileType
@export var tile_texture : Texture2D
@export var width : int
@export var move_range_horiz : int
@export var move_range_vert : int
@export var speed : int
@export var interval : float
@export var switchable : bool = false
## Optional pulley wheel (a Node2D, usually a child) mounted above the lift. When
## set, rope strands are drawn from the wheel down to the deck and the wheel spins
## as the platform travels, so the moving platform reads as a rope-and-pulley
## elevator instead of a free-floating slab.
@export var wheel_path : NodePath
@export var rope_color : Color = Color(0.40, 0.28, 0.15)
@onready var platform_body = $PlatformBody

@onready var collision_shape : CollisionShape2D = $PlatformBody/CollisionShape2D


const TILE_SIZE : int = 16
const ROPE_SPIN_PER_PX : float = 0.06

enum TileType {
	GRASS,
	STONE,
}

var tween : Tween
var _wheel : Node2D
var _ropes : Array[Line2D] = []
var _last_body_y : float = 0.0

func _ready():
	if not width:
		width = 4
	collision_shape.shape.size.x = width * TILE_SIZE - 6
	collision_shape.shape.size.y = 2 * TILE_SIZE - 8
	collision_shape.position.x = width * TILE_SIZE * 0.5
	collision_shape.position.y = TILE_SIZE - 4
	
	for i in width:
		create_sprite(i)

	if not Engine.is_editor_hint() and not wheel_path.is_empty():
		_wheel = get_node_or_null(wheel_path)
		if _wheel:
			_setup_ropes()

	if not switchable:
		animate()

func _physics_process(_delta : float) -> void:
	if _ropes.is_empty() or not is_instance_valid(_wheel):
		return
	_update_ropes()

## Two rope strands strung from the pulley wheel down to the deck corners. Lives on
## the (stationary) platform root so the points can be recomputed in world space as
## the deck body rises and falls.
func _setup_ropes() -> void:
	_last_body_y = platform_body.global_position.y
	for _i in 2:
		var line := Line2D.new()
		line.width = 2.0
		line.default_color = rope_color
		line.joint_mode = Line2D.LINE_JOINT_ROUND
		line.z_index = -1
		add_child(line)
		_ropes.append(line)
	_update_ropes()

func _update_ropes() -> void:
	var wheel_pos : Vector2 = _wheel.global_position
	var deck_origin : Vector2 = platform_body.global_position
	var anchors := [
		Vector2(deck_origin.x + width * TILE_SIZE * 0.25, deck_origin.y),
		Vector2(deck_origin.x + width * TILE_SIZE * 0.75, deck_origin.y),
	]
	for i in _ropes.size():
		var r := _ropes[i]
		r.clear_points()
		r.add_point(r.to_local(wheel_pos))
		r.add_point(r.to_local(anchors[i]))
	# Spin the wheel in proportion to how far the deck travelled this frame, so the
	# rope looks like it's being reeled over the pulley.
	_wheel.rotation += (deck_origin.y - _last_body_y) * ROPE_SPIN_PER_PX
	_last_body_y = deck_origin.y

func animate():
	var initial_position : Vector2 = global_position
	var offset_vector : Vector2
	offset_vector = Vector2(move_range_horiz * TILE_SIZE, -move_range_vert * TILE_SIZE)
	if tween:
		tween.kill()
	tween = create_tween().set_loops().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT).set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	tween.tween_property(platform_body, "global_position", initial_position + offset_vector, offset_vector.length() / speed / TILE_SIZE)
	tween.tween_interval(interval)
	tween.tween_property(platform_body, "global_position", initial_position, offset_vector.length() / speed / TILE_SIZE)
	tween.tween_interval(interval)

func stop():
	tween.kill()
	
func create_sprite(idx : int):
	var sprite = Sprite2D.new()
	sprite.centered = false
	sprite.region_enabled = true
	sprite.position = Vector2(TILE_SIZE * idx, 0)
	sprite.region_rect.size = Vector2(TILE_SIZE, 2 * TILE_SIZE)
	if idx != 0 and idx != width - 1:
		idx = 1
	elif idx == width - 1:
		idx = 2
	sprite.region_rect.position = Vector2(TILE_SIZE * idx, 2 * TILE_SIZE * tile_type)

	sprite.texture = tile_texture
	platform_body.call_deferred("add_child", sprite)

func _on_lever_activated():
	animate()

func _on_lever_deactivated():
	stop()
