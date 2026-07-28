extends Node2D
class_name SeeSaw

## Lever & fulcrum CATAPULT (KSSR 10.1.1 / 10.1.2).
##
## A balance beam on a central fulcrum. The player steps onto an arm and their
## weight (the EFFORT) tips that side down — a see-saw. Standing on the LEFT arm
## raises a "press E" prompt: pressing it drops a heavy BOULDER (a big LOAD) onto
## the RIGHT arm, which slams down and flings the player up and over the wall.
## A lever turns a small effort plus a heavy load into a powerful launch.
##
## The Beam is an AnimatableBody2D rotated about the fulcrum each physics frame so
## it carries the rider. Pads (children of the beam) sense which arm is loaded.

signal player_nearby(node)
signal player_left

## Gentle tilt the beam takes under the standing player's weight, in degrees.
@export var tilt_degrees : float = 9.0
## Harder tilt when the boulder slams the right arm down.
@export var slam_degrees : float = 13.0
@export var tilt_speed : float = 9.0
## Velocity the player is flung with: +x toward the wall, -y is up.
@export var launch_velocity : Vector2 = Vector2(300.0, -720.0)
## How high above the right arm the boulder spawns, and how long it takes to fall.
@export var boulder_drop_height : float = 380.0
@export var boulder_fall_time : float = 0.45

@onready var _beam : AnimatableBody2D = $Beam

var _left_loaded : bool = false
var _right_loaded : bool = false
var _firing : bool = false

func _ready() -> void:
	add_to_group("Interactables")
	if _beam:
		_beam.sync_to_physics = true

func _physics_process(delta : float) -> void:
	if not _beam:
		return
	var target := deg_to_rad(_target_tilt())
	_beam.rotation = lerp_angle(_beam.rotation, target, clampf(tilt_speed * delta, 0.0, 1.0))

## Positive rotation lowers the RIGHT arm; negative lowers the LEFT arm.
func _target_tilt() -> float:
	if _firing:
		return slam_degrees
	if _left_loaded and not _right_loaded:
		return -tilt_degrees
	if _right_loaded and not _left_loaded:
		return tilt_degrees
	return 0.0

## E-press routed from the Level. Only the LEFT arm arms the catapult.
func interact() -> void:
	if _firing or not _left_loaded:
		return
	_fire()

func _fire() -> void:
	_firing = true
	player_left.emit()   # dismiss the prompt while it fires
	var boulder := _spawn_boulder()
	var tween := create_tween()
	tween.tween_property(boulder, "position", Vector2(96.0, -16.0), boulder_fall_time) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_callback(_on_boulder_impact.bind(boulder))

func _on_boulder_impact(boulder : Node2D) -> void:
	AudioManager.play_sfx("crusher")
	if _left_loaded and Globals.player and Globals.player.has_method("catapult"):
		Globals.player.catapult(launch_velocity)
	# Boulder rebounds off the slammed arm and tumbles out of sight.
	var tween := create_tween()
	tween.tween_property(boulder, "position:y", boulder.position.y + 220.0, 0.55) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(boulder, "modulate:a", 0.0, 0.55)
	tween.tween_callback(boulder.queue_free)
	# Let the beam settle level again so the puzzle can be retried.
	await get_tree().create_timer(0.7).timeout
	_firing = false

func _spawn_boulder() -> Node2D:
	var boulder := Polygon2D.new()
	boulder.color = Color(0.32, 0.30, 0.28)
	var pts := PackedVector2Array()
	for i in 11:
		var a : float = TAU * float(i) / 11.0
		var rr : float = 26.0 * (0.82 + 0.18 * float(i % 3) / 2.0)
		pts.append(Vector2(cos(a) * rr, sin(a) * rr))
	boulder.polygon = pts
	boulder.position = Vector2(96.0, -boulder_drop_height)
	boulder.z_index = 2
	add_child(boulder)
	return boulder

func _is_player(body : Node) -> bool:
	return body == Globals.player or body is Sciquest

func _on_left_pad_body_entered(body : Node2D) -> void:
	if _is_player(body):
		_left_loaded = true
		if not _firing:
			player_nearby.emit(self)   # show "press E" only on the left arm

func _on_left_pad_body_exited(body : Node2D) -> void:
	if _is_player(body):
		_left_loaded = false
		player_left.emit()

func _on_right_pad_body_entered(body : Node2D) -> void:
	if _is_player(body):
		_right_loaded = true

func _on_right_pad_body_exited(body : Node2D) -> void:
	if _is_player(body):
		_right_loaded = false
