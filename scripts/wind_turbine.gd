extends Node2D
class_name WindTurbine

@export var crystal_id : String = ""
@export var spin_speed : float = 4.0  # radians per second

@onready var _blades : Sprite2D = $Blades

var _spinning : bool = false
var _audio : AudioStreamPlayer

func _ready() -> void:
	_audio = AudioStreamPlayer.new()
	_audio.volume_db = -5.0
	var raw := load("res://sound/wind turbine sfx.mp3") as AudioStream
	if raw:
		var dup := raw.duplicate() as AudioStream
		if dup is AudioStreamMP3:
			(dup as AudioStreamMP3).loop = true
		_audio.stream = dup
	add_child(_audio)

func _process(delta: float) -> void:
	if _spinning and _blades:
		_blades.rotation += spin_speed * delta

func _on_lever_activated() -> void:
	if _spinning:
		return
	_spinning = true
	_audio.play()
	EventBus.crystal_lit.emit(self)

func _on_lever_deactivated() -> void:
	if not _spinning:
		return
	_spinning = false
	_audio.stop()
	EventBus.crystal_unlit.emit(self)
