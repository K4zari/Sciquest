extends Node
class_name CaveGenerator

# Heightmap-walker cave generator for a 2D side-scrolling platformer.
# Produces ONE continuous walkable floor with small step changes, a wavy
# ceiling above, and optional small bumps on the ground. Drops in as a
# child of a Level and runs before the parent's _ready() spawns the player.

@export var width: int = 80
@export var height: int = 50

# Floor surface (depth = tiles measured up from the bottom edge).
@export var floor_min_depth: int = 4
@export var floor_max_depth: int = 14
# Plateau length range — each flat run stays at one height for this many columns.
@export var min_plateau_length: int = 4
@export var max_plateau_length: int = 12
# How many tiles the floor steps up or down at each plateau boundary.
@export_range(1, 3, 1) var floor_step_size: int = 1

# Ceiling (depth = tiles measured down from the top edge).
@export var ceiling_min_depth: int = 4
@export var ceiling_max_depth: int = 12
@export_range(0, 3, 1) var max_ceiling_step: int = 2

# Optional 1-tile bumps the player can hop over (default off for clean walking).
@export_range(0.0, 1.0, 0.01) var bump_chance: float = 0.0

# 0 = randomize; otherwise reproducible.
@export var generation_seed: int = 0

@export var solid_source_id: int = 1
@export var solid_atlas_coords: Vector2i = Vector2i(4, 3)
@export var tilemap_layer: int = 0
@export var tilemap_path: NodePath = ^"../TileMap"
@export var spawn_marker_path: NodePath = ^"../PlayerSpawnSpot"
@export var bottom_border_collision_path: NodePath = ^"../BottomBorder/CollisionShape2D"

const WALL := 1
const FLOOR := 0

var _grid: Array = []
var _floor_top_y: Array[int] = []
var _rng := RandomNumberGenerator.new()

func _ready() -> void:
	if generation_seed == 0:
		_rng.randomize()
	else:
		_rng.seed = generation_seed

	var tilemap := get_node_or_null(tilemap_path) as TileMap
	if tilemap == null:
		push_error("CaveGenerator: TileMap not found at %s" % tilemap_path)
		return

	_init_empty()
	_carve_floor()
	_carve_ceiling()
	_scatter_bumps()
	_paint(tilemap)
	_place_spawn(tilemap)
	_extend_bottom_border(tilemap)
	_extend_camera_limits(tilemap)

func _init_empty() -> void:
	_grid.clear()
	for x in width:
		var col: Array = []
		for y in height:
			col.append(FLOOR)
		_grid.append(col)

func _carve_floor() -> void:
	_floor_top_y.clear()
	var depth: int = _rng.randi_range(floor_min_depth + 1, floor_max_depth - 1)
	var run_left: int = _rng.randi_range(min_plateau_length, max_plateau_length)
	for x in width:
		var top_y: int = height - depth
		_floor_top_y.append(top_y)
		for y in range(top_y, height):
			_grid[x][y] = WALL
		run_left -= 1
		if run_left <= 0:
			var direction: int = 1 if _rng.randf() < 0.5 else -1
			var new_depth: int = depth + direction * floor_step_size
			# If the chosen direction would clamp, flip it to keep level changes visible.
			if new_depth < floor_min_depth or new_depth > floor_max_depth:
				direction = -direction
				new_depth = depth + direction * floor_step_size
			depth = clamp(new_depth, floor_min_depth, floor_max_depth)
			run_left = _rng.randi_range(min_plateau_length, max_plateau_length)

func _carve_ceiling() -> void:
	var depth: int = _rng.randi_range(ceiling_min_depth + 1, ceiling_max_depth - 1)
	for x in width:
		depth = clamp(depth + _rng.randi_range(-max_ceiling_step, max_ceiling_step), ceiling_min_depth, ceiling_max_depth)
		for y in depth:
			_grid[x][y] = WALL

func _scatter_bumps() -> void:
	if bump_chance <= 0.0:
		return
	# Skip the first few columns so spawn area stays clean.
	for x in range(6, width - 2):
		if _rng.randf() < bump_chance:
			var top_y: int = _floor_top_y[x]
			if top_y - 1 >= 0:
				_grid[x][top_y - 1] = WALL

func _paint(tilemap: TileMap) -> void:
	tilemap.clear_layer(tilemap_layer)
	for x in width:
		for y in height:
			if _grid[x][y] == WALL:
				tilemap.set_cell(tilemap_layer, Vector2i(x, y), solid_source_id, solid_atlas_coords)

func _place_spawn(tilemap: TileMap) -> void:
	var spawn := get_node_or_null(spawn_marker_path) as Marker2D
	if spawn == null:
		return
	var tile_size: Vector2i = tilemap.tile_set.tile_size
	# Stand on the first column whose tile above the floor is open (no bump).
	for x in range(2, width - 2):
		var top_y: int = _floor_top_y[x]
		var stand_y: int = top_y - 1
		if stand_y >= 0 and _grid[x][stand_y] == FLOOR:
			spawn.position = Vector2(
				(x + 0.5) * tile_size.x,
				(stand_y + 0.5) * tile_size.y
			)
			return

func _extend_camera_limits(tilemap: TileMap) -> void:
	# Wait two frames so the parent Level._ready() can spawn the player and
	# Globals.player gets set by the player's own _ready().
	await get_tree().process_frame
	await get_tree().process_frame
	if Globals.player == null:
		return
	var camera := Globals.player.get_node_or_null("Camera") as Camera2D
	if camera == null:
		return
	var tile_size: Vector2i = tilemap.tile_set.tile_size
	camera.limit_left = 0
	camera.limit_right = width * tile_size.x
	camera.limit_top = 0
	camera.limit_bottom = height * tile_size.y

func _extend_bottom_border(tilemap: TileMap) -> void:
	var border := get_node_or_null(bottom_border_collision_path) as CollisionShape2D
	if border == null:
		return
	var tile_size: Vector2i = tilemap.tile_set.tile_size
	var new_shape := WorldBoundaryShape2D.new()
	# WorldBoundaryShape2D normal defaults to (0, -1); negative distance pushes
	# the kill plane downward in world space. Add 4 tiles of slack.
	new_shape.distance = -(height * tile_size.y + 4 * tile_size.y)
	border.shape = new_shape
