extends MarginContainer

@onready var anim_sprite : AnimatedSprite2D = $AnimatedSprite2D
@onready var border : TextureRect = $Border
@onready var timer : Timer = $Timer
@onready var effect_frame : TextureProgressBar = $EffectFrame

func _ready():
	_apply_character_face()
	anim_sprite.play("default")
	timer.wait_time = randf_range(1.5, 2.0)
	timer.start()

# Point every portrait frame at the chosen character's face sheet so the healthbar
# portrait matches the selected hero (Globals.selected_character).
func _apply_character_face() -> void:
	var tex : Texture2D = load(Globals.get_player_face_path())
	if tex == null:
		return
	var frames : SpriteFrames = anim_sprite.sprite_frames
	for anim_name in frames.get_animation_names():
		for i in frames.get_frame_count(anim_name):
			var atlas : Texture2D = frames.get_frame_texture(anim_name, i)
			if atlas is AtlasTexture:
				atlas.atlas = tex

func set_effect_color(color : Color):
	effect_frame.tint_progress = color
	
func update_effect(value : float):
	effect_frame.value = value
	
func ouch():
	anim_sprite.play("ouch")
	var tw = create_tween().set_ease(Tween.EASE_OUT)
	tw.tween_property(border, "modulate", Color.RED, 0.1)
	tw.tween_property(border, "modulate", Color.WHITE, 0.1)

func _on_animated_sprite_2d_animation_finished():
	if anim_sprite.animation == "ouch":
		anim_sprite.play("default")
		timer.wait_time = randf_range(1.5, 2.0)	
		timer.start()
		
func _on_timer_timeout():
	if anim_sprite.animation == "default":
		if anim_sprite.frame == 0:
			anim_sprite.frame = randi() % 7
		else:
			anim_sprite.frame = 0
		timer.wait_time = randf_range(1.5, 2.0)	
		timer.start()
