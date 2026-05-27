extends Node2D
class_name WindTurbine

@export var crystal_id : String = ""
@export var anim_name : String = "spin"

@onready var anim : AnimationPlayer = $AnimationPlayer if has_node("AnimationPlayer") else null

var _spinning : bool = false

func _on_lever_activated() -> void:
	if _spinning:
		return
	_spinning = true
	if anim and anim.has_animation(anim_name):
		anim.play(anim_name)
	EventBus.crystal_lit.emit(self)

func _on_lever_deactivated() -> void:
	if not _spinning:
		return
	_spinning = false
	if anim:
		anim.stop()
	EventBus.crystal_unlit.emit(self)
