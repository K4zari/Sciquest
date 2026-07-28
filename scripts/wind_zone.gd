@tool
extends Area2D
class_name WindZone
## A gust of wind that pushes enemies sideways while active. Wire it as a target
## of a Lever (it implements _on_lever_activated/_deactivated) so the same pull
## that spins the wind turbine switches the gust on. Detects enemies (layer 5)
## via collision_mask = 16 and feeds them start_wind() each frame.

@export var push_speed : float = 200.0
@export var active : bool = false:
	set(value):
		active = value
		_apply_active()

func _ready() -> void:
	if Engine.is_editor_hint():
		_apply_active()
		return
	monitoring = true
	body_entered.connect(_on_body_entered)
	_apply_active()

func _physics_process(_delta : float) -> void:
	if Engine.is_editor_hint() or not active:
		return
	for body in get_overlapping_bodies():
		if body is BasicEnemy and not body.is_dead:
			body.start_wind(Vector2(push_speed, 0.0))

func _on_body_entered(body : Node) -> void:
	if active and body is BasicEnemy and not body.is_dead:
		body.start_wind(Vector2(push_speed, 0.0))

func _on_lever_activated() -> void:
	active = true

func _on_lever_deactivated() -> void:
	active = false
	for e in get_tree().get_nodes_in_group("Enemies"):
		if e is BasicEnemy:
			e.stop_wind()

func _apply_active() -> void:
	var p := get_node_or_null("Particles") as CPUParticles2D
	if p:
		p.emitting = active
