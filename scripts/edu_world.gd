extends Node2D

# Flip to true to use the procedural cave-generator prototype for topic 5.
const USE_PROCEDURAL_CAVE := true

const TOPIC_LEVEL_SCENES := {
	4: "res://scenes/level_4_plants.tscn",      # Forest
	5: "res://scenes/level_5_light.tscn",       # Cave / Crystal
	7: "res://scenes/level_7_energy.tscn",      # Volcano / Industrial
	9: "res://scenes/level_9_earth.tscn",       # Space / Planet
	10: "res://scenes/level_10_machines.tscn",  # Steampunk Factory
}
const PROCEDURAL_OVERRIDES := {
	5: "res://scenes/level_5_light_v2.tscn",
}
const FALLBACK_LEVEL_SCENE := "res://scenes/level_1.tscn"

@onready var hud : CanvasLayer = $HUD

var _current_level : Node = null
var _current_menu : Control = null

var _main_menu_scene := preload("res://scenes/main_menu.tscn")
var _char_select_scene := preload("res://scenes/character_select.tscn")
var _level_select_scene := preload("res://scenes/level_select.tscn")
var _player_scene := preload("res://scenes/forresta_2.tscn")

func _ready():
	hud.visible = false
	_show_main_menu()

func _show_main_menu():
	_swap_menu(_main_menu_scene.instantiate())
	_current_menu.play_pressed.connect(_show_character_select)

func _show_character_select():
	_swap_menu(_char_select_scene.instantiate())
	_current_menu.character_chosen.connect(_show_level_select)
	_current_menu.back_pressed.connect(_show_main_menu)

func _show_level_select():
	_swap_menu(_level_select_scene.instantiate())
	_current_menu.topic_chosen.connect(_start_level)
	_current_menu.back_pressed.connect(_show_character_select)

func _start_level(topic_id: int):
	if _current_menu:
		_current_menu.queue_free()
		_current_menu = null

	Globals.current_topic = topic_id
	BattleManager.reset_session()

	var scene_path : String = TOPIC_LEVEL_SCENES.get(topic_id, FALLBACK_LEVEL_SCENE)
	if USE_PROCEDURAL_CAVE and PROCEDURAL_OVERRIDES.has(topic_id):
		scene_path = PROCEDURAL_OVERRIDES[topic_id]
	if not ResourceLoader.exists(scene_path):
		push_warning("Level scene missing for topic %d (%s) — falling back to %s" % [topic_id, scene_path, FALLBACK_LEVEL_SCENE])
		scene_path = FALLBACK_LEVEL_SCENE
	var level : Level = load(scene_path).instantiate()
	level.topic_id = topic_id
	level.player_scene = _player_scene
	level.game_over.connect(_on_game_over)
	_current_level = level
	call_deferred("add_child", level)

	hud.visible = true
	EventBus.level_end_reached.connect(_on_level_completed, CONNECT_ONE_SHOT)

func _on_level_completed(_level):
	Globals.completed_topics.append(Globals.current_topic)
	_cleanup_level()
	_show_level_select()

func _on_game_over(_level):
	_cleanup_level()
	_show_level_select()

func _cleanup_level():
	hud.visible = false
	if _current_level:
		_current_level.queue_free()
		_current_level = null
	Globals.player_data = null
	Globals.player_inventory = null
	Globals.player = null

func _swap_menu(new_menu: Control):
	if _current_menu:
		_current_menu.queue_free()
	_current_menu = new_menu
	add_child(_current_menu)

func _input(event):
	if not event is InputEventKey or not event.pressed:
		return
	match event.keycode:
		KEY_ESCAPE:
			if _current_level:
				_cleanup_level()
				_show_level_select()
			else:
				get_tree().quit()
		KEY_I:
			if _current_level:
				var inv = hud.get_node_or_null("Control/Inventory")
				if inv:
					inv.visible = not inv.visible
		KEY_D:
			if _current_level:
				var sw = hud.get_node_or_null("Control/StatusWindow")
				if sw:
					sw.visible = not sw.visible
