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

var _line_pool : Array[Line2D] = []
var _glow_pool : Array[Line2D] = []
var _last_hits : Array = []

func _physics_process(_delta : float):
	if enabled:
		_update_beam()
	else:
		_hide_all_segments()
		_last_hits.clear()

func _update_beam() -> void:
	var space := get_world_2d().direct_space_state
	var origin : Vector2 = global_position
	var direction : Vector2 = Vector2.RIGHT.rotated(global_rotation)
	var current_intensity : float = intensity
	var exclude : Array = []
	var new_hits : Array = []
	var segments : Array = []

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
			segments.append({"start": origin, "end": origin + direction * BEAM_LENGTH, "intensity": current_intensity})
			break

		var collider = hit.collider
		var hit_pos : Vector2 = hit.position
		var hit_normal : Vector2 = hit.normal
		if not is_instance_valid(collider) or not collider is Node:
			segments.append({"start": origin, "end": hit_pos, "intensity": current_intensity})
			break

		segments.append({"start": origin, "end": hit_pos, "intensity": current_intensity})

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

	_render_segments(segments)
	_emit_hit_changes(new_hits)
	_last_hits = new_hits

func _render_segments(segments : Array) -> void:
	for i in segments.size():
		var seg : Dictionary = segments[i]
		var seg_intensity : float = seg.intensity
		var alpha : float = beam_color.a * seg_intensity
		var seg_color := Color(beam_color.r, beam_color.g, beam_color.b, alpha)
		var glow_color := Color(beam_color.r, beam_color.g, beam_color.b, alpha * 0.25)
		var pts := PackedVector2Array([to_local(seg.start), to_local(seg.end)])

		var line := _get_segment_line(i, false)
		line.points = pts
		line.default_color = seg_color
		line.visible = true

		var glow := _get_segment_line(i, true)
		glow.points = pts
		glow.default_color = glow_color
		glow.visible = true

	for i in range(segments.size(), _line_pool.size()):
		_line_pool[i].visible = false
	for i in range(segments.size(), _glow_pool.size()):
		_glow_pool[i].visible = false

func _hide_all_segments() -> void:
	for line in _line_pool:
		line.visible = false
	for line in _glow_pool:
		line.visible = false

func _get_segment_line(idx : int, is_glow : bool) -> Line2D:
	var pool : Array[Line2D] = _glow_pool if is_glow else _line_pool
	while pool.size() <= idx:
		var line := Line2D.new()
		line.width = beam_width * (3.5 if is_glow else 1.0)
		line.joint_mode = Line2D.LINE_JOINT_BEVEL
		line.begin_cap_mode = Line2D.LINE_CAP_ROUND
		line.end_cap_mode = Line2D.LINE_CAP_ROUND
		line.z_index = 4 if is_glow else 5
		add_child(line)
		pool.append(line)
	return pool[idx]

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
