extends State

func enter_state(_previous_state : State):
	animator.stop()
	if actor.ballistic_launch:
		# Catapult: fly along the launch vector with no horizontal damping.
		actor.velocity = actor.pending_launch
		actor.pending_launch = Vector2.ZERO
		pivot.rotation = 0
	else:
		pivot.rotation -= pivot.scale.x * PI / 4
		actor.velocity = Vector2(-pivot.scale.x * actor.SPEED * 1.25, actor.JUMP_VELOCITY * 0.5)
	actor.sprite.frame = 37

func physics_update(delta):
	actor.velocity.y += actor.gravity * delta

	if not actor.ballistic_launch:
		actor.velocity.x = move_toward(actor.velocity.x, 0, actor.SPEED * delta)

	if actor.is_on_floor() and actor.velocity.y > 0:
		pivot.rotation = 0
		actor.ballistic_launch = false
		transition.emit("IdleState")

	actor.move_and_slide()
