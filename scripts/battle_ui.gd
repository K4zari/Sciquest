extends CanvasLayer

signal answer_chosen(index: int)
signal continue_pressed

var _question_label: RichTextLabel
var _option_buttons: Array[Button] = []
var _answer_grid: GridContainer
var _feedback_panel: PanelContainer
var _feedback_label: RichTextLabel
var _continue_button: Button
var _player_hp_label: Label
var _enemy_hp_label: Label
var _enemy_name_label: Label
var _topic_label: Label
var _question_num_label: Label

func _ready():
	layer = 10
	_build_ui()

func _build_ui():
	var panel_bg := StyleBoxFlat.new()
	panel_bg.bg_color = Color(0, 0, 0, 0.78)
	panel_bg.border_color = Color(0.8, 0.7, 0.3, 0.9)
	panel_bg.border_width_top = 2
	panel_bg.border_width_bottom = 2
	panel_bg.content_margin_left = 12
	panel_bg.content_margin_right = 12
	panel_bg.content_margin_top = 8
	panel_bg.content_margin_bottom = 8

	# ── Top panel: header + question ─────────────────────────────────────────
	var top_panel := PanelContainer.new()
	top_panel.add_theme_stylebox_override("panel", panel_bg)
	top_panel.custom_minimum_size.y = 90
	add_child(top_panel)
	top_panel.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE, Control.PRESET_MODE_MINSIZE)

	var top_vbox := VBoxContainer.new()
	top_vbox.add_theme_constant_override("separation", 4)
	top_panel.add_child(top_vbox)

	var header := HBoxContainer.new()
	top_vbox.add_child(header)

	_topic_label = Label.new()
	_topic_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_topic_label.add_theme_font_size_override("font_size", 9)
	_topic_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	header.add_child(_topic_label)

	_question_num_label = Label.new()
	_question_num_label.add_theme_font_size_override("font_size", 9)
	_question_num_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	header.add_child(_question_num_label)

	_question_label = RichTextLabel.new()
	_question_label.bbcode_enabled = true
	_question_label.fit_content = true
	_question_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_question_label.add_theme_font_size_override("normal_font_size", 12)
	top_vbox.add_child(_question_label)

	# ── Bottom panel: HP row + answers/feedback ──────────────────────────────
	var bottom_panel := PanelContainer.new()
	bottom_panel.add_theme_stylebox_override("panel", panel_bg)
	bottom_panel.custom_minimum_size.y = 130
	add_child(bottom_panel)
	bottom_panel.anchor_left = 0.0
	bottom_panel.anchor_right = 1.0
	bottom_panel.anchor_top = 1.0
	bottom_panel.anchor_bottom = 1.0
	bottom_panel.offset_left = 0
	bottom_panel.offset_right = 0
	bottom_panel.offset_top = -135
	bottom_panel.offset_bottom = -5

	var bottom_vbox := VBoxContainer.new()
	bottom_vbox.add_theme_constant_override("separation", 5)
	bottom_panel.add_child(bottom_vbox)

	var hp_row := HBoxContainer.new()
	hp_row.add_theme_constant_override("separation", 10)
	bottom_vbox.add_child(hp_row)

	_player_hp_label = Label.new()
	_player_hp_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_player_hp_label.add_theme_font_size_override("font_size", 10)
	hp_row.add_child(_player_hp_label)

	_enemy_name_label = Label.new()
	_enemy_name_label.add_theme_font_size_override("font_size", 10)
	_enemy_name_label.add_theme_color_override("font_color", Color(0.9, 0.4, 0.3))
	hp_row.add_child(_enemy_name_label)

	_enemy_hp_label = Label.new()
	_enemy_hp_label.add_theme_font_size_override("font_size", 10)
	hp_row.add_child(_enemy_hp_label)

	_answer_grid = GridContainer.new()
	_answer_grid.columns = 2
	_answer_grid.add_theme_constant_override("h_separation", 6)
	_answer_grid.add_theme_constant_override("v_separation", 4)
	bottom_vbox.add_child(_answer_grid)

	var option_colors: Array[Color] = [
		Color("#2967a0"),  # A: blue
		Color("#29919a"),  # B: green
		Color("#dd9d26"),  # C: yellow
		Color("#c54d65"),  # D: red
	]

	for i in range(4):
		var btn := Button.new()
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.custom_minimum_size.y = 28
		btn.add_theme_font_size_override("font_size", 10)
		btn.add_theme_color_override("font_color", Color.WHITE)
		btn.add_theme_color_override("font_hover_color", Color.WHITE)
		btn.add_theme_color_override("font_pressed_color", Color.WHITE)
		btn.add_theme_color_override("font_disabled_color", Color(1, 1, 1, 0.85))
		var base_color: Color = option_colors[i]
		btn.add_theme_stylebox_override("normal", _make_button_style(base_color))
		btn.add_theme_stylebox_override("hover", _make_button_style(base_color.lightened(0.15)))
		btn.add_theme_stylebox_override("pressed", _make_button_style(base_color.darkened(0.2)))
		btn.add_theme_stylebox_override("disabled", _make_button_style(base_color))
		btn.add_theme_stylebox_override("focus", _make_button_style(base_color, true))
		var captured_i := i
		btn.pressed.connect(func(): answer_chosen.emit(captured_i))
		_answer_grid.add_child(btn)
		_option_buttons.append(btn)

	_feedback_panel = PanelContainer.new()
	_feedback_panel.visible = false
	bottom_vbox.add_child(_feedback_panel)

	var fb_vbox := VBoxContainer.new()
	fb_vbox.add_theme_constant_override("separation", 3)
	_feedback_panel.add_child(fb_vbox)

	_feedback_label = RichTextLabel.new()
	_feedback_label.bbcode_enabled = true
	_feedback_label.fit_content = true
	_feedback_label.custom_minimum_size.y = 28
	_feedback_label.add_theme_font_size_override("normal_font_size", 10)
	fb_vbox.add_child(_feedback_label)

	_continue_button = Button.new()
	_continue_button.text = "Continue ▶"
	_continue_button.custom_minimum_size.y = 24
	_continue_button.add_theme_font_size_override("font_size", 10)
	_continue_button.pressed.connect(func(): continue_pressed.emit())
	fb_vbox.add_child(_continue_button)

func _make_button_style(color: Color, focus: bool = false) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = color
	sb.corner_radius_top_left = 4
	sb.corner_radius_top_right = 4
	sb.corner_radius_bottom_left = 4
	sb.corner_radius_bottom_right = 4
	sb.content_margin_left = 8
	sb.content_margin_right = 8
	sb.content_margin_top = 4
	sb.content_margin_bottom = 4
	if focus:
		sb.border_width_left = 2
		sb.border_width_right = 2
		sb.border_width_top = 2
		sb.border_width_bottom = 2
		sb.border_color = Color.WHITE
	return sb

# ─────────────────────────────────────────────────────────────────────────────

func setup_question(question: Dictionary, q_num: int,
		player_hp: float, player_max_hp: float,
		enemy_hearts: int, enemy_max_hearts: int,
		enemy_name: String, topic_name: String):
	_topic_label.text = topic_name
	_question_num_label.text = "  Q%d" % q_num
	_question_label.text = "[b]%s[/b]" % question.question

	var labels := ["A", "B", "C", "D"]
	for i in range(4):
		_option_buttons[i].text = "%s. %s" % [labels[i], question.options[i]]
		_option_buttons[i].disabled = false
		_option_buttons[i].modulate = Color.WHITE

	_feedback_panel.visible = false
	_update_hp(player_hp, player_max_hp, enemy_hearts, enemy_max_hearts, enemy_name)

func update_hp_bars(player_hp: float, player_max_hp: float,
		enemy_hearts: int, enemy_max_hearts: int):
	_update_hp(player_hp, player_max_hp, enemy_hearts, enemy_max_hearts, _enemy_name_label.text)

func _update_hp(player_hp: float, player_max_hp: float,
		enemy_hearts: int, enemy_max_hearts: int, enemy_name: String):
	_player_hp_label.text = "You: HP %d/%d" % [int(ceil(player_hp)), int(player_max_hp)]
	_enemy_name_label.text = enemy_name
	_enemy_hp_label.text = "♥".repeat(enemy_hearts) + "♡".repeat(enemy_max_hearts - enemy_hearts)

func show_feedback(correct: bool, correct_index: int, explanation: String):
	for i in range(4):
		_option_buttons[i].disabled = true
		_option_buttons[i].modulate = Color(0.5, 0.5, 0.5)
	_option_buttons[correct_index].modulate = Color(0.3, 1.0, 0.3)

	if correct:
		_feedback_label.text = "[color=lime][b]Correct![/b][/color]  " + explanation
	else:
		_feedback_label.text = "[color=red][b]Wrong.[/b][/color]  Correct answer: [b]%s[/b].  %s" % [
			["A","B","C","D"][correct_index], explanation
		]
	_continue_button.text = "Continue ▶"
	_answer_grid.visible = false
	_feedback_panel.visible = true

func show_battle_result(won: bool, questions_answered: int):
	_answer_grid.visible = false
	if won:
		_feedback_label.text = "[color=lime][b]Battle Won![/b][/color]\nGreat work — you defeated the enemy in %d questions." % questions_answered
		_continue_button.text = "Continue ▶"
	else:
		_feedback_label.text = "[color=red][b]Battle Lost.[/b][/color]\nReview the explanations above, then try again. Respawning at last checkpoint..."
		_continue_button.text = "Respawn ▶"
	_feedback_panel.visible = true

func reset_for_next_question():
	_answer_grid.visible = true
	_feedback_panel.visible = false
	for btn in _option_buttons:
		btn.visible = true
