extends Area2D

@onready var sprite = $Sprite2D

@export_multiline var description : String
@export var board_visible : bool = true

func _ready():
	sprite.visible = board_visible

func _on_body_entered(_body):
	# Don't pop the info-board dialog over an active quiz battle — if the player
	# walked onto a board mid-attack, the battle takes priority.
	if BattleManager.is_active():
		return
	DialogManager.show_dialog(self, tr(description))

func _on_body_exited(_body):
	DialogManager.hide_dialog(self)
