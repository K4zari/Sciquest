extends Node

const SFX_PATHS: Dictionary = {
	"jump":           "res://sound/player jump.wav",
	"attack":         "res://sound/player attack.mp3",
	"enemy_hurt":     "res://sound/enemy hurt.mp3",
	"player_hurt":    "res://sound/player hurt.wav",
	"player_dies":    "res://sound/player dies.wav",
	"enemy_dies":     "res://sound/enemy dies.mp3",
	"player_respawn": "res://sound/player respawns.wav",
	"ui_click":       "res://sound/ui click sfx.wav",
	"lever":          "res://sound/lever sfx.mp3",
	"gate_open":      "res://sound/gate open sfx.mp3",
	"crusher":        "res://sound/crusher.wav",
	"level_complete": "res://sound/Level Complete.wav",
	# Procedurally-generated 8-bit SFX (see tools/generate_sfx.py)
	"dash":            "res://sound/dash.wav",
	"slide":           "res://sound/slide.wav",
	"land":            "res://sound/land.wav",
	"answer_correct":  "res://sound/answer correct.wav",
	"answer_wrong":    "res://sound/answer wrong.wav",
	"chest_open":      "res://sound/chest open.wav",
	"checkpoint":      "res://sound/checkpoint.wav",
	"orb_pickup":      "res://sound/orb pickup.wav",
	"generator_power": "res://sound/generator power.wav",
	"mirror_rotate":   "res://sound/mirror rotate.wav",
	"crystal_lit":     "res://sound/crystal lit.wav",
}

const MUSIC_PATHS: Dictionary = {
	"main_menu": "res://sound/main menu music.mp3",
	"level_4":   "res://sound/Level 4 Background Music.mp3",
	"level_5":   "res://sound/Level 5 Background Music.mp3",
	"level_7":   "res://sound/Level 7 Background Music.mp3",
	"level_9":   "res://sound/Level 9 Background Music.mp3",
	"boss":      "res://sound/Final boss music.mp3",
}

## Default playback level for music, with per-track overrides (dB). The main-menu
## theme sits a little quieter than the in-game tracks.
const MUSIC_BASE_VOLUME_DB: float = -8.0
const MUSIC_VOLUME_DB: Dictionary = {
	"main_menu": -16.0,
}

const TOPIC_TO_MUSIC: Dictionary = {
	4:  "level_4",
	5:  "level_5",
	7:  "level_7",
	9:  "level_9",
	10: "level_7",
}

const SFX_POOL_SIZE: int = 6

var _music_player: AudioStreamPlayer
var _sfx_players: Array[AudioStreamPlayer] = []
var _sfx_index: int = 0
var _current_music: String = ""

func _ready() -> void:
	_music_player = AudioStreamPlayer.new()
	_music_player.volume_db = MUSIC_BASE_VOLUME_DB
	add_child(_music_player)
	# Safety net: if a track ever reaches its end (e.g. an import that wasn't
	# flagged to loop), restart it so music never silently drops out mid-level
	# or mid-boss-fight. Intentional stops clear _current_music first.
	_music_player.finished.connect(_on_music_finished)
	for i in SFX_POOL_SIZE:
		var p := AudioStreamPlayer.new()
		add_child(p)
		_sfx_players.append(p)
	get_tree().node_added.connect(_on_node_added)
	BattleManager.battle_ended.connect(_on_battle_ended)

## Auto-wire every Button in the scene tree for UI click sound.
func _on_node_added(node: Node) -> void:
	if node is BaseButton:
		if not node.pressed.is_connected(_play_ui_click):
			node.pressed.connect(_play_ui_click)

func _play_ui_click() -> void:
	play_sfx("ui_click", -8.0)

func play_sfx(key: String, volume_db: float = 0.0) -> void:
	var path: String = SFX_PATHS.get(key, "")
	if path.is_empty() or not ResourceLoader.exists(path):
		return
	var player: AudioStreamPlayer = _sfx_players[_sfx_index]
	_sfx_index = (_sfx_index + 1) % SFX_POOL_SIZE
	player.stream = load(path)
	player.volume_db = volume_db
	player.play()

func play_music(key: String) -> void:
	var path: String = MUSIC_PATHS.get(key, "")
	if path.is_empty() or not ResourceLoader.exists(path):
		return
	if _current_music == key and _music_player.playing:
		return
	_current_music = key
	var stream: AudioStream = (load(path) as AudioStream).duplicate()
	if stream is AudioStreamMP3:
		(stream as AudioStreamMP3).loop = true
	elif stream is AudioStreamWAV:
		(stream as AudioStreamWAV).loop_mode = AudioStreamWAV.LOOP_FORWARD
	_music_player.volume_db = MUSIC_VOLUME_DB.get(key, MUSIC_BASE_VOLUME_DB)
	_music_player.stream = stream
	_music_player.play()

func _on_music_finished() -> void:
	# A looping stream never emits finished; if we get here the import wasn't
	# baked to loop, so replay the same already-assigned stream (no reload).
	if _current_music == "":
		return
	_music_player.play()

func stop_music() -> void:
	_music_player.stop()
	_current_music = ""

func get_level_music_key(topic_id: int) -> String:
	return TOPIC_TO_MUSIC.get(topic_id, "")

func resume_level_music() -> void:
	var key := get_level_music_key(Globals.current_topic)
	if key != "":
		play_music(key)

func _on_battle_ended(_won: bool, _correct: int, _total: int) -> void:
	if _current_music == "boss":
		resume_level_music()
