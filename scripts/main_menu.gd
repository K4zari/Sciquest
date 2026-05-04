extends Control

signal play_pressed

func _ready():
	var vp := get_viewport_rect().size
	size = vp
	position = Vector2.ZERO
	_build_ui(vp)

func _build_ui(vp: Vector2):
	var bg := ColorRect.new()
	bg.color = Color(0.05, 0.08, 0.12)
	bg.size = vp
	add_child(bg)

	var center := CenterContainer.new()
	center.size = vp
	add_child(center)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 12)
	center.add_child(vbox)

	var title := Label.new()
	title.text = "SciQuest"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 28)
	title.add_theme_color_override("font_color", Color(0.3, 0.9, 0.4))
	vbox.add_child(title)

	var subtitle := Label.new()
	subtitle.text = "Year 4 Science Adventure"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_font_size_override("font_size", 10)
	subtitle.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	vbox.add_child(subtitle)

	var spacer := Control.new()
	spacer.custom_minimum_size.y = 16
	vbox.add_child(spacer)

	var play_btn := Button.new()
	play_btn.text = "  Start Learning  "
	play_btn.custom_minimum_size = Vector2(160, 32)
	play_btn.pressed.connect(func(): play_pressed.emit())
	vbox.add_child(play_btn)

	var quit_btn := Button.new()
	quit_btn.text = "  Quit  "
	quit_btn.custom_minimum_size = Vector2(160, 28)
	quit_btn.pressed.connect(func(): get_tree().quit())
	vbox.add_child(quit_btn)

	var footer := Label.new()
	footer.text = "Plants  •  Light  •  Energy  •  Earth  •  Machines"
	footer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	footer.add_theme_font_size_override("font_size", 8)
	footer.add_theme_color_override("font_color", Color(0.4, 0.4, 0.4))
	footer.position = Vector2(0, vp.y - 20)
	footer.size.x = vp.x
	add_child(footer)
