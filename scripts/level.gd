extends Node2D
class_name Level

var player_scene : PackedScene

@onready var player_spawn_spot : Marker2D = $PlayerSpawnSpot

@export var exit_up : bool
@export var exit_right : bool
@export var exit_down : bool
@export var exit_left : bool
@export var max_tombstones : int = 10
@export var topic_id : int = 4
@export var camera_limit_bottom_override : int = 0
@export var bottom_border_y_override : int = 0
@export var camera_offset_y_override : int = 0

var tombstones : Array = []

var tw : Tween
var player : CharacterBody2D

var interactable_in_range : Node
var _interact_prompt : InteractPrompt

# True while the player is inside a darkened cave so we can undo the darkness
# (and the cave's camera/border tweaks) if they die down there and respawn.
var _in_cave : bool = false

var _level_start_time : float = 0.0
var _enemies_defeated : int = 0
var _total_enemies : int = 0
var _death_count : int = 0
var _questions_correct : int = 0
var _questions_total : int = 0

var pickable_scene : PackedScene = preload("res://scenes/pickable.tscn")
var tomb_texture = preload("res://graphics/environment/tombstone.png")

signal game_over

func _input(event):
	if event.is_action_pressed("interact"):
		if !interactable_in_range:
			return
		if interactable_in_range is Mirror:
			return
		interactable_in_range.interact()

func _process(delta):
	if interactable_in_range is Mirror and Input.is_action_pressed("interact"):
		interactable_in_range.continuous_rotate(delta)
			
func _ready():
	Globals.current_topic = topic_id
	Globals.clear_energy()
	if not player_scene:
		player_scene = load("res://scenes/sciquest_2.tscn")
	player = player_scene.instantiate()
	player.global_position = player_spawn_spot.global_position
	add_child(player)
	_interact_prompt = InteractPrompt.new()
	add_child(_interact_prompt)
	if camera_limit_bottom_override != 0:
		player.camera.limit_bottom = camera_limit_bottom_override
	if bottom_border_y_override != 0:
		move_bottom_border(-bottom_border_y_override)
	if camera_offset_y_override != 0:
		player.camera.position.y = camera_offset_y_override
	connect_signals()

	# Baseline enemy count for the end-of-level score. Counted now (children are
	# ready before the level), so later-summoned minions don't inflate the total —
	# this measures how many of the level's own enemies the player engaged.
	_total_enemies = get_tree().get_nodes_in_group("Enemies").size()

	_level_start_time = Time.get_ticks_msec() / 1000.0
	if not BattleManager.battle_ended.is_connected(_on_battle_ended):
		BattleManager.battle_ended.connect(_on_battle_ended)

	var _music_key := AudioManager.get_level_music_key(topic_id)
	if _music_key != "":
		AudioManager.play_music(_music_key)

	SceneChanger.fade_in()

	
func create_tombstone(location : Vector2):
	if tombstones.size() == max_tombstones:
		var tomb = tombstones.pop_front()
		tomb.queue_free()
	var sprite = Sprite2D.new()
	sprite.texture = tomb_texture
	sprite.offset.y = -12
	sprite.global_position = location
	sprite.z_index = -2
	tombstones.append(sprite)
	call_deferred("add_child", sprite)
	
		
func connect_signals():		
	for interactable in get_tree().get_nodes_in_group("Interactables"):
		if interactable.has_signal("player_nearby"):
			interactable.player_nearby.connect(_on_player_near_interactable)
		if interactable.has_signal("player_left"):
			interactable.player_left.connect(_on_player_left_interactable)
	for entrance in get_tree().get_nodes_in_group("CaveEntrances"):
		entrance.cave_entered.connect(cave_entered)
		entrance.cave_exited.connect(cave_exited)
	for checkpoint in get_tree().get_nodes_in_group("Checkpoints"):
		checkpoint.checkpoint_reached.connect(_on_checkpoint_reached)
	if not EventBus.interactable_spawned.is_connected(_on_interactable_spawned):
		EventBus.interactable_spawned.connect(_on_interactable_spawned)

	player.ghost_spawned.connect(_on_ghost_spawned)
	player.died.connect(_on_player_died)
	player.teleport_ended.connect(_on_player_teleported)
	player.soul_released.connect(_on_player_soul_released)
	player.effect_spawned.connect(_on_entity_spawned)

func _on_enemy_spawned(enemy : CharacterBody2D):
	if enemy.has_signal("projectile_fired"):
		enemy.projectile_fired.connect(_on_projectile_spawned)
	if enemy.has_signal("died"):
		enemy.died.connect(_on_monster_died)
	if enemy is NightBorne:
		enemy.tilemap = $TileMap

func _on_pickable_dropped(item : Globals.Pickups):
	var drop_position = player.global_position + Vector2(player.pivot.scale.x * 16, -8)
	var pickable : Pickable = pickable_scene.instantiate() as Pickable
	pickable.type = item
	pickable.position = drop_position
	call_deferred("add_child", pickable)
		
func _on_player_died(place_tombstone : bool = true):
	_death_count += 1
	await get_tree().create_timer(1.0).timeout
	SceneChanger.fade_out()
	await get_tree().create_timer(1.0).timeout
	if place_tombstone:
		create_tombstone(player.global_position)
	player.global_position = player_spawn_spot.global_position
	player.reset()
	# Dying inside a dark cave used to respawn the player with the darkness (and the
	# cave's camera/border tweaks) still applied. Undo it now; walking back through the
	# CaveEntrance re-triggers cave_entered(), so resetting to "outside" is always safe.
	if _in_cave:
		cave_exited()
	AudioManager.play_sfx("player_respawn")
	await get_tree().create_timer(1.0).timeout
	SceneChanger.fade_in()

func respawn_player() -> void:
	# Manual "unstuck" — warp the player back to the last checkpoint/spawn spot
	# when they get wedged in geometry or fall under the map. Unlike dying, this
	# does not count toward the death tally or drop a tombstone.
	SceneChanger.fade_out()
	await get_tree().create_timer(0.8).timeout
	player.global_position = player_spawn_spot.global_position
	player.velocity = Vector2.ZERO
	player.reset()
	if _in_cave:
		cave_exited()
	AudioManager.play_sfx("player_respawn")
	await get_tree().create_timer(0.3).timeout
	SceneChanger.fade_in()

func _on_entity_spawned(entity : Node2D):
	add_child(entity)

func _on_ghost_spawned(ghost : Sprite2D):
	call_deferred("add_child", ghost)

func _on_projectile_spawned(projectile : Node2D):
	if projectile.has_signal("explosion_spawned"):
		projectile.explosion_spawned.connect(_on_spawn_fireball_explosion)
	call_deferred("add_child", projectile)
	
func _on_spawn_fireball_explosion(explosion : AnimatedSprite2D):
	call_deferred("add_child", explosion)
	
func _on_interactable_spawned(node: Node):
	if node.has_signal("player_nearby") and not node.player_nearby.is_connected(_on_player_near_interactable):
		node.player_nearby.connect(_on_player_near_interactable)
	if node.has_signal("player_left") and not node.player_left.is_connected(_on_player_left_interactable):
		node.player_left.connect(_on_player_left_interactable)

func _on_player_near_interactable(interactable: Node):
	interactable_in_range = interactable
	if _interact_prompt and interactable is Node2D:
		_interact_prompt.show_at(interactable.global_position + Vector2(0, -24))

func _on_player_left_interactable():
	interactable_in_range = null
	if _interact_prompt:
		_interact_prompt.dismiss()

func _on_monster_died(monster):
	_enemies_defeated += 1
	if monster.is_boss and monster.teleport_guarded:
		monster.teleport_guarded.activate()
	monster.queue_free()

func _on_battle_ended(_won : bool, correct : int, total : int):
	_questions_correct += correct
	_questions_total += total

func get_completion_stats() -> Dictionary:
	var elapsed : float = (Time.get_ticks_msec() / 1000.0) - _level_start_time
	return {
		"elapsed": elapsed,
		"correct": _questions_correct,
		"total": _questions_total,
		"enemies_defeated": _enemies_defeated,
		"enemies_total": _total_enemies,
		"deaths": _death_count,
		"topic_id": topic_id,
	}


func _on_player_teleported():
	if tw:
		tw.kill()
	tw = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	tw.tween_property($CanvasModulate, "color", Color(1.0, 1.0, 1.0), 0.25)
	
func _on_player_soul_released(soul : Sprite2D):
	soul.tree_exited.connect(_on_player_died.bind(false))
	call_deferred("add_child", soul)


func _on_bottom_border_body_entered(_body):
	_on_player_died(false)


func _on_checkpoint_reached(_pos : Vector2):
	player_spawn_spot.global_position = _pos

func cave_entered(max_depth : int):
	_in_cave = true
	if tw:
		tw.kill()
	tw = create_tween()
	tw.tween_property($CanvasModulate, "color", Color(0.1, 0.1, 0.1, 1), 0.5)
	$TileMap.set_layer_enabled(3, false)
	for light in get_tree().get_nodes_in_group("Lights"):
		light.activate()
	move_bottom_border(-max_depth - 128)
	Globals.player.camera.limit_bottom = max_depth
	
func cave_exited():
	_in_cave = false
	if tw:
		tw.kill()
	tw = create_tween()
	tw.tween_property($CanvasModulate, "color", Color.WHITE, 0.5)
	$TileMap.set_layer_enabled(3, true)
	for light in get_tree().get_nodes_in_group("Lights"):
		light.deactivate()
	move_bottom_border(-512)
	Globals.player.camera.limit_bottom = 999
	
func move_bottom_border(dist : int):
	$BottomBorder/CollisionShape2D.shape.distance = dist
		
func _on_tree_entered():
	EventBus.enemy_spawned.connect(_on_enemy_spawned)
