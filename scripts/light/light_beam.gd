extends Node2D
class_name LightBeam

const MAX_BOUNCES := 12
const BEAM_LENGTH := 3000.0
const NUDGE := 1.0

@export var beam_color : Color = Color(1.0, 0.95, 0.55, 0.85)
@export var beam_width : float = 3.0
@export var collision_mask : int = 0xFFFFFFFF
@export_range(0.0, 1.0) var intensity : float = 1.0
@export var enabled : bool = true

var _line : Line2D
var _last_hits : Array = []

func _ready():
	_line = Line2D.new()
	_line.width = beam_width
	_line.default_color = beam_color
	_line.joint_mode = Line2D.LINE_JOINT_BEVEL
	_line.begin_cap_mode = Line2D.LINE_CAP_ROUND
	_line.end_cap_mode = Line2D.LINE_CAP_ROUND
	_line.z_index = 5
	add_child(_line)

func _physics_process(_delta : float):
	if enabled:
		_update_beam()
	else:
		_line.points = PackedVector2Array()
		_last_hits.clear()

func _update_beam() -> void:
	var space := get_world_2d().direct_space_state
	var origin : Vector2 = global_position
	var direction : Vector2 = Vector2.RIGHT.rotated(global_rotation)
	var current_intensity : float = intensity
	var points : PackedVector2Array = [Vector2.ZERO]
	var exclude : Array = []
	var new_hits : Array = []

	for bounce in MAX_BOUNCES:
		var query := PhysicsRayQueryParameters2D.create(
			origin,
			origin + direction * BEAM_LENGTH,
			collision_mask,
			exclude
		)
		query.collide_with_areas = true
		query.collide_with_bodies = true

		var hit : Dictionary = space.intersect_ray(query)

		if hit.is_empty():
			points.append(to_local(origin + direction * BEAM_LENGTH))
			break

		var collider = hit.collider
		var hit_pos : Vector2 = hit.position
		var hit_normal : Vector2 = hit.normal
		if not is_instance_valid(collider) or not collider is Node:
			break
		points.append(to_local(hit_pos))

		var stop : bool = _handle_hit(collider, hit_pos, hit_normal, current_intensity, new_hits, exclude)
		if stop:
			break

		# Update for next iteration based on what happened
		if collider.is_in_group("Mirrors") and collider.has_method("reflect"):
			direction = collider.reflect(direction)
			origin = hit_pos + direction * NUDGE
			exclude = [collider.get_rid()]
		elif collider.is_in_group("TransparentMaterials"):
			origin = hit_pos + direction * NUDGE
			exclude.append(collider.get_rid())
		elif collider.is_in_group("TranslucentMaterials"):
			var attenuation : float = 0.5
			if collider.has_method("get_attenuation"):
				attenuation = collider.get_attenuation()
			current_intensity *= attenuation
			origin = hit_pos + direction * NUDGE
			exclude.append(collider.get_rid())
		else:
			break

	_line.points = points
	_emit_hit_changes(new_hits)
	_last_hits = new_hits

func _handle_hit(collider, _hit_pos : Vector2, _hit_normal : Vector2, current_intensity : float, new_hits : Array, _exclude : Array) -> bool:
	# Returns true if the beam should stop after this hit.
	if collider.is_in_group("LightCrystals"):
		if collider.has_method("on_beam_hit"):
			collider.on_beam_hit(current_intensity)
		new_hits.append(collider)
		return true

	if collider.is_in_group("Mirrors"):
		new_hits.append(collider)
		return false

	if collider.is_in_group("TransparentMaterials"):
		return false

	if collider.is_in_group("TranslucentMaterials"):
		new_hits.append(collider)
		return false

	# OpaqueMaterials or any unclassified collider — beam stops.
	new_hits.append(collider)
	return true

func _emit_hit_changes(new_hits : Array) -> void:
	for h in new_hits:
		if h not in _last_hits:
			EventBus.beam_hit.emit(h, intensity)
