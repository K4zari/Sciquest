extends Control

signal topic_chosen(topic_id: int)
signal back_pressed

const TOPICS := [
	{"id": 4,  "name": "Topic 4",  "subtitle": "Plants",
	 "desc": "Explore the forest\nand learn about plants!",
	 "color": Color(0.15, 0.7, 0.2)},
	{"id": 5,  "name": "Topic 5",  "subtitle": "Properties of Light",
	 "desc": "Crystal caves hide\nthe secrets of light!",
	 "color": Color(0.9, 0.9, 0.15)},
	{"id": 7,  "name": "Topic 7",  "subtitle": "Energy",
	 "desc": "Face the volcano\nand master energy!",
	 "color": Color(0.9, 0.35, 0.1)},
	{"id": 9,  "name": "Topic 9",  "subtitle": "Earth",
	 "desc": "Journey to space\nand explore our planet!",
	 "color": Color(0.2, 0.45, 0.9)},
	{"id": 10, "name": "Topic 10", "subtitle": "Machines",
	 "desc": "Navigate the factory\nand master machines!",
	 "color": Color(0.65, 0.35, 0.85)},
]

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
	title.text = "Choose a Topic"
	title.add_theme_font_size_override("font_size", 16)
	title.add_theme_color_override("font_color", Color(0.9, 0.85, 0.3))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.size.x = vp.x
	title.position = Vector2(0, 14)
	add_child(title)

	var char_lbl := Label.new()
	char_lbl.text = "Playing as: %s" % Globals.selected_character.capitalize()
	char_lbl.add_theme_font_size_override("font_size", 8)
	char_lbl.add_theme_color_override("font_color", Color(0.55, 0.55, 0.55))
	char_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	char_lbl.size.x = vp.x
	char_lbl.position = Vector2(0, 36)
	add_child(char_lbl)

	# 5 cards laid out horizontally
	var margin := 12.0
	var gap := 8.0
	var card_w := (vp.x - margin * 2 - gap * 4) / 5.0
	var card_h := vp.y - 80.0
	var card_y := 52.0

	for i in range(TOPICS.size()):
		var t: Dictionary = TOPICS[i]
		var card_x := margin + i * (card_w + gap)
		_make_card(Vector2(card_x, card_y), card_w, card_h, t)

	# Back button
	var back_btn := Button.new()
	back_btn.text = " Back "
	back_btn.position = Vector2(12, vp.y - 32)
	back_btn.custom_minimum_size = Vector2(70, 24)
	back_btn.pressed.connect(func(): back_pressed.emit())
	add_child(back_btn)

func _make_card(pos: Vector2, w: float, h: float, topic: Dictionary):
	var panel := PanelContainer.new()
	panel.position = pos
	panel.custom_minimum_size = Vector2(w, h)
	add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 4)
	panel.add_child(vbox)

	# Color bar at top
	var bar := ColorRect.new()
	bar.color = topic.color
	bar.custom_minimum_size = Vector2(0, 4)
	vbox.add_child(bar)

	var topic_lbl := Label.new()
	topic_lbl.text = topic.name
	topic_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	topic_lbl.add_theme_font_size_override("font_size", 8)
	topic_lbl.add_theme_color_override("font_color", Color(0.55, 0.55, 0.55))
	vbox.add_child(topic_lbl)

	var sub_lbl := Label.new()
	sub_lbl.text = topic.subtitle
	sub_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub_lbl.add_theme_font_size_override("font_size", 10)
	sub_lbl.add_theme_color_override("font_color", topic.color)
	sub_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(sub_lbl)

	var desc_lbl := Label.new()
	desc_lbl.text = topic.desc
	desc_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc_lbl.add_theme_font_size_override("font_size", 7)
	desc_lbl.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_lbl.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(desc_lbl)

	if Globals.completed_topics.has(topic.id):
		var done_lbl := Label.new()
		done_lbl.text = "✓ Completed"
		done_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		done_lbl.add_theme_font_size_override("font_size", 8)
		done_lbl.add_theme_color_override("font_color", Color(0.3, 1.0, 0.3))
		vbox.add_child(done_lbl)

	var play_btn := Button.new()
	play_btn.text = "Play"
	play_btn.custom_minimum_size.y = 24
	play_btn.pressed.connect(func(): topic_chosen.emit(topic.id))
	vbox.add_child(play_btn)
