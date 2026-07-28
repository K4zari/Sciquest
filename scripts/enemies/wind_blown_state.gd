extends State
class_name WindBlownState
## Enemy is caught in a wind gust (see scripts/wind_zone.gd) and shoved sideways
## until it tumbles off the platform and falls away, or the wind stops and it
## lands back on solid ground.

const PUSH_ACCEL := 3.0   # how quickly velocity ramps toward the wind speed
const TUMBLE_SPIN := 7.0  # sprite spin (rad/s) for the blown-away look

func enter_state(_previous_state : State) -> void:
	if animator:
		animator.stop()

func exit_state() -> void:
	if actor.sprite:
		actor.sprite.rotation = 0.0

func physics_update(delta : float) -> void:
	actor.velocity.y += actor.gravity * delta
	if actor.in_wind:
		actor.velocity.x = move_toward(actor.velocity.x, actor.wind_force.x,
			absf(actor.wind_force.x) * PUSH_ACCEL * delta)
	else:
		actor.velocity.x = move_toward(actor.velocity.x, 0.0, actor.SPEED * delta)
	actor.move_and_slide()

	if actor.sprite:
		actor.sprite.rotation += TUMBLE_SPIN * delta * signf(actor.wind_force.x)

	# Tumbled into the pit below the level — remove it.
	if actor.global_position.y > actor.wind_kill_y:
		actor.blow_away_despawn()
		return
	# Wind stopped and we settled back on the ground — resume normal behaviour.
	if not actor.in_wind and actor.is_on_floor() and absf(actor.velocity.x) < 1.0:
		transition.emit("IdleState")
