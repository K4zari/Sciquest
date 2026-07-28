extends State
class_name AttackState

signal spawn_fireball()

@export var colors : Array[Color]

func enter_state(_prev_state : State):
	AudioManager.play_sfx("attack")
	actor.attack_buffer = false
	var material = actor.sprite.get_material()
	material.set_shader_parameter("is_attacking", true)
	actor.velocity.x = 0
	actor.combo_timer.stop()
	actor.attacks_performed += 1
	if actor.attacks_performed < 3:
		animator.play("Attack", -1, 1.6)
	else:
		animator.play("ComboAttack", -1, 1.6)

func exit_state():
	var material = actor.sprite.get_material()
	material.set_shader_parameter("is_attacking", false)

func physics_update(delta):
	actor.velocity.y += actor.gravity * delta
	

		
	actor.move_and_slide()
	
func animation_finished():
	transition.emit("IdleState")
	actor.combo_timer.start()
	if actor.attacks_performed == 3:
		actor.attacks_performed = 0

func apply_effect():
	var material = actor.sprite.material
	material.set_shader_parameter("target_color", Globals.affinity_colors[actor.affinity])

func remove_effect():
	var material = actor.sprite.material
	material.set_shader_parameter("target_color", Color.WHITE)	

func execute_command(command : Sciquest.Commands):
	if not accepted_commands.has(command) and command != Sciquest.Commands.RELEASE:
		return false
	if command == Sciquest.Commands.ATTACK:
		actor.attack_buffer = true
		actor.attack_buffer_timer.start()
	return true
