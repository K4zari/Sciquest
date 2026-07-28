extends Node

var player : Sciquest

enum Affinities {
	FIRE,
	WATER,
	ICE,
	#AIR,
	ACID,
	ELECTRICITY,
	POISON,
	NONE,
}

enum Pickups {
	POTION_HEALTH,
	POTION_STAMINA,
	POTION_SPEED,
	POTION_MANA,
	POTION_STRENGTH,
	TOME_CONSTITUTION,
	TOME_ENDURANCE,
	TOME_AGILITY,
	TOME_MANA,
	TOME_STRENGTH,
	KEY_GOLD,
	KEY_SILVER,
	KEY_RED,
	KEY_BLUE
}

var pickup_names : Dictionary = {
	Pickups.POTION_HEALTH : "Potion of Health",
	Pickups.POTION_STAMINA : "Potion of Stamina",
	Pickups.POTION_SPEED : "Potion of Speed",
	Pickups.POTION_MANA : "Potion of Mana",
	Pickups.POTION_STRENGTH : "Potion of Strength",
	Pickups.KEY_GOLD : "Gold Key",
	Pickups.KEY_SILVER : "Silver Key",
	Pickups.KEY_RED : "Red Key",
	Pickups.KEY_BLUE : "Blue Key",
	Pickups.TOME_CONSTITUTION : "Tome of Constitution",
	Pickups.TOME_AGILITY : "Tome of Agility",
	Pickups.TOME_ENDURANCE : "Tome of Endurance",
	Pickups.TOME_MANA : "Tome of Mana",
	Pickups.TOME_STRENGTH : "Tome of Strength"
}

var pickup_descriptions : Dictionary = {
	Pickups.POTION_HEALTH : "Restores your health",
	Pickups.POTION_STAMINA : "Restores your stamina",
	Pickups.POTION_SPEED : "Temporary speed boost",
	Pickups.POTION_MANA : "Restores your mana",
	Pickups.POTION_STRENGTH : "Temporary damage boost",
	Pickups.KEY_GOLD : "",
	Pickups.KEY_SILVER : "",
	Pickups.KEY_RED : "",
	Pickups.KEY_BLUE : "",
	Pickups.TOME_CONSTITUTION : "Increases constitution",
	Pickups.TOME_AGILITY : "Increases agility",
	Pickups.TOME_ENDURANCE : "Increases Endurance",
	Pickups.TOME_MANA : "Icreases max mana",
	Pickups.TOME_STRENGTH : "Increases strength"
} 

var affinity_interactions : Dictionary = {
	Affinities.FIRE : {
		Affinities.FIRE : 1.0,
		Affinities.WATER : 2.0,
		Affinities.ICE : 0.5,
		#Affinities.AIR : 1.0,
		Affinities.ACID : 1.0,
		Affinities.ELECTRICITY : 1.0,
		Affinities.POISON: 1.0,
		Affinities.NONE : 0.5
	},
	
	Affinities.WATER : {
		Affinities.FIRE : 0.5,
		Affinities.WATER : 1.0,
		Affinities.ICE : 1.5,
		#Affinities.AIR : 1.0,
		Affinities.ACID : 1.0,
		Affinities.ELECTRICITY : 1.5,
		Affinities.POISON: 1.0,
		Affinities.NONE : 0.5
	},
	
	Affinities.ICE : {
		Affinities.FIRE : 2.0,
		Affinities.WATER : 1.5,
		Affinities.ICE : 1.0,
		#Affinities.AIR : 0.5,
		Affinities.ACID : 0.5,
		Affinities.ELECTRICITY : 1.0,
		Affinities.POISON: 1.0,
		Affinities.NONE : 0.5
	},
	
#	Affinities.AIR : {
#		Affinities.FIRE : 1.5,
#		Affinities.WATER : 0.5,
#		Affinities.ICE : 1.0,
#		#Affinities.AIR : 1.0,
#		Affinities.ACID : 1.0,
#		Affinities.ELECTRICITY : 1.0,
#		Affinities.POISON: 1.5,
#		Affinities.NONE : 0.5
#	},
	Affinities.ACID : {
		Affinities.FIRE : 1.0,
		Affinities.WATER : 1.5,
		Affinities.ICE : 1.25,
		#Affinities.AIR : 1.0,
		Affinities.ACID : 1.0,
		Affinities.ELECTRICITY : 0.5,
		Affinities.POISON: 0.5,
		Affinities.NONE : 0.5
	},
		
	Affinities.ELECTRICITY : {
		Affinities.FIRE : 1.0,
		Affinities.WATER : 0.5,
		Affinities.ICE : 1.0,
		#Affinities.AIR : 1.0,
		Affinities.ACID : 1.0,
		Affinities.ELECTRICITY : 1.0,
		Affinities.POISON: 1.0,
		Affinities.NONE : 0.5
	},
	
	Affinities.POISON : {
		Affinities.FIRE : 1.0,
		Affinities.WATER : 2.0,
		Affinities.ICE : 1.0,
		#Affinities.AIR : 1.0,
		Affinities.ACID : 1.0,
		Affinities.ELECTRICITY : 1.0,
		Affinities.POISON: 1.0,
		Affinities.NONE : 0.5
	},
	
	Affinities.NONE : {
	Affinities.FIRE : 1.5,
	Affinities.WATER : 1.5,
	Affinities.ICE : 1.5,
	#Affinities.AIR : 1.5,
	Affinities.ACID : 1.5,
	Affinities.ELECTRICITY : 1.5,
	Affinities.POISON: 1.5,
	Affinities.NONE : 1.0
}
}

var affinity_colors : Dictionary = {
	Affinities.FIRE : Color(1.0, 0.2, 0.2),
	Affinities.WATER : Color(0.3, 0.5, 0.9),
	Affinities.ICE : Color(0.7, 0.9, 0.9),
	#Affinities.AIR : Color.SKY_BLUE,
	Affinities.ACID : Color(0.15, 0.8, 0.2),
	Affinities.ELECTRICITY : Color(0.95, 0.9, 0.05),
	Affinities.POISON : Color(0.8, 0.25, 0.9),
	Affinities.NONE : Color.DARK_GRAY
}



var affinity_gradients : Dictionary = {
	Globals.Affinities.FIRE : "res://resources/fire_gradient_texture_1d.tres",
	Globals.Affinities.ICE : "res://resources/ice_gradient_texture_1d.tres",
	Globals.Affinities.ACID : "res://resources/acid_gradient_texture_1d.tres",
	Globals.Affinities.POISON : "res://resources/poison_gradient_texture_1d.tres"
}

const TILE_SIZE : int = 16

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var tombstone_locations : Array[Vector2] = []



func cantor(a : int, b : int) -> int:
	return int(0.5 * (a + b) * (a + b + 1) + b)

var player_data : StatsManager
var player_inventory : Inventory

var current_topic : int = 4
var selected_character : String = "male"

## "en" or "ms" (Bahasa Melayu). Switching re-points TranslationServer's locale
## so every tr() call across the game (menus, HUD, battles, info boards, quiz
## questions) immediately renders in the chosen language.
var language : String = "en"

func set_language(lang_code : String) -> void:
	language = lang_code
	TranslationServer.set_locale(lang_code)

func _ready():
	var ms := Translation.new()
	ms.locale = "ms"
	var _msgs := MalayStrings.get_messages()
	for key in _msgs:
		ms.add_message(key, _msgs[key])
	TranslationServer.add_translation(ms)
const PLAYER_SHEET_PATHS : Dictionary = {
	"male": "res://graphics/spritesheets/sciquest_ahmad.png",
	"female": "res://graphics/spritesheets/sciquest_aishah.png",
}
const PLAYER_SHEET_FALLBACK : String = "res://graphics/spritesheets/sciquest_spritesheet.png"

# HUD status-portrait face sheets (28x28 frames). Aishah uses the original auburn
# face sheet; Ahmad uses the brown-hair recolor so the healthbar portrait matches
# the chosen character.
const PLAYER_FACE_PATHS : Dictionary = {
	"male": "res://graphics/spritesheets/sciquest_faces_32x32_ahmad.png",
	"female": "res://graphics/spritesheets/sciquest_faces_32x32.png",
}
const PLAYER_FACE_FALLBACK : String = "res://graphics/spritesheets/sciquest_faces_32x32.png"

func get_player_sheet_path() -> String:
	var path : String = PLAYER_SHEET_PATHS.get(selected_character, PLAYER_SHEET_FALLBACK)
	if not ResourceLoader.exists(path):
		return PLAYER_SHEET_FALLBACK
	return path

func get_player_face_path() -> String:
	var path : String = PLAYER_FACE_PATHS.get(selected_character, PLAYER_FACE_FALLBACK)
	if not ResourceLoader.exists(path):
		return PLAYER_FACE_FALLBACK
	return path

var completed_topics : Array[int] = []
var level_best_stars : Dictionary = {}  # topic_id (int) -> stars (1..3)

# Every topic except the tutorial (0). Clearing all of these triggers the
# one-time congratulations finale.
const REQUIRED_TOPIC_IDS : Array[int] = [4, 5, 7, 9, 10]
var all_topics_celebrated : bool = false

func all_required_topics_complete() -> bool:
	for id in REQUIRED_TOPIC_IDS:
		if not completed_topics.has(id):
			return false
	return true

# ── Energy inventory (Topic 7 puzzle) ────────────────────────────────────────
# Collected FuelOrb.Source values. Filled by grabbing orbs from chests, drained
# by feeding the correct orb to a generator. Cleared on each fresh level load.
var energy_orbs : Array[int] = []

func add_energy(source : int) -> void:
	if not energy_orbs.has(source):
		energy_orbs.append(source)

func has_energy(source : int) -> bool:
	return energy_orbs.has(source)

func remove_energy(source : int) -> void:
	energy_orbs.erase(source)

func clear_energy() -> void:
	energy_orbs.clear()

func record_stars(topic_id : int, stars : int) -> bool:
	var prev : int = level_best_stars.get(topic_id, 0)
	if stars > prev:
		level_best_stars[topic_id] = stars
		return true
	return false

func add_tombstone(tombstone : Vector2):
	tombstone_locations.append(tombstone)
	if tombstone_locations.size() > 10:
		tombstone_locations.pop_front()

signal player_ready(_player : Sciquest)
