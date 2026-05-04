extends Control

signal character_chosen
signal back_pressed

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

	# Title
	var title := Label.new()
	title.text = "Choose Your Character"
	title.add_theme_font_size_override("font_size", 18)
	title.add_theme_color_override("font_color", Color(0.9, 0.85, 0.3))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.size.x = vp.x
	title.position = Vector2(0, 24)
	add_child(title)

	# Character cards row centered
	var card_w := 110.0
	var card_h := 150.0
	var gap := 30.0
	var total_w := card_w * 2 + gap
	var start_x := (vp.x - total_w) * 0.5
	var card_y := (vp.y - card_h) * 0.5

	_make_card(Vector2(start_x, card_y), card_w, card_h,
		"Ahmad", "male",
		"res://graphics/characters/male_child/ahmad_portrait.png",
		Color(0.3, 0.6, 1.0))

	_make_card(Vector2(start_x + card_w + gap, card_y), card_w, card_h,
		"Aishah", "female",
		"res://graphics/characters/female_child/aishah_portrait.png",
		Color(1.0, 0.4, 0.7))

	# Back button
	var back_btn := Button.new()
	back_btn.text = " Back "
	back_btn.position = Vector2(16, vp.y - 36)
	back_btn.custom_minimum_size = Vector2(70, 26)
	back_btn.pressed.connect(func(): back_pressed.emit())
	add_child(back_btn)

func _make_card(pos: Vector2, w: float, h: float,
		char_name: String, char_key: String,
		portrait_path: String, color: Color):
	var panel := PanelContainer.new()
	panel.position = pos
	panel.custom_minimum_size = Vector2(w, h)
	add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	panel.add_child(vbox)

	var portrait := TextureRect.new()
	portrait.custom_minimum_size = Vector2(w - 16, 72)
	portrait.expand_mode = TextureRect.EXPAND_FIT_HEIGHT_PROPORTIONAL
	portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	if ResourceLoader.exists(portrait_path):
		portrait.texture = load(portrait_path)
	vbox.add_child(portrait)

	var name_lbl := Label.new()
	name_lbl.text = char_name
	name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_lbl.add_theme_color_override("font_color", color)
	name_lbl.add_theme_font_size_override("font_size", 12)
	vbox.add_child(name_lbl)

	var btn := Button.new()
	btn.text = "Select"
	btn.custom_minimum_size.y = 26
	btn.pressed.connect(func():
		Globals.selected_character = char_key
		character_chosen.emit()
	)
	vbox.add_child(btn)
