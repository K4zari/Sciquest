extends CanvasLayer
class_name LevelCompleteScreen

signal continue_pressed

const FILLED_STAR := "★"
const HOLLOW_STAR := "☆"

var _header_label : Label
var _topic_label : Label
var _stars_label : Label
var _new_best_label : Label
var _time_value : Label
var _correct_value : Label
var _wrong_value : Label
var _enemies_value : Label
var _deaths_value : Label
var _continue_button : Button

func _ready():
	layer = 20
	_build_ui()

func _build_ui():
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.7)
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	dim.anchor_right = 1.0
	dim.anchor_bottom = 1.0
	add_child(dim)

	var center := CenterContainer.new()
	center.anchor_right = 1.0
	center.anchor_bottom = 1.0
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(center)

	var panel_bg := StyleBoxFlat.new()
	panel_bg.bg_color = Color(0.05, 0.05, 0.08, 0.95)
	panel_bg.border_color = Color(0.95, 0.8, 0.25, 1.0)
	panel_bg.border_width_top = 3
	panel_bg.border_width_bottom = 3
	panel_bg.border_width_left = 3
	panel_bg.border_width_right = 3
	panel_bg.corner_radius_top_left = 10
	panel_bg.corner_radius_top_right = 10
	panel_bg.corner_radius_bottom_left = 10
	panel_bg.corner_radius_bottom_right = 10
	panel_bg.content_margin_left = 14
	panel_bg.content_margin_right = 14
	panel_bg.content_margin_top = 10
	panel_bg.content_margin_bottom = 10

	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", panel_bg)
	panel.custom_minimum_size = Vector2(260, 0)
	center.add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 5)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	panel.add_child(vbox)

	_header_label = Label.new()
	_header_label.text = "LEVEL COMPLETE!"
	_header_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_header_label.add_theme_font_size_override("font_size", 14)
	_header_label.add_theme_color_override("font_color", Color(1.0, 0.9, 0.4))
	vbox.add_child(_header_label)

	_topic_label = Label.new()
	_topic_label.text = ""
	_topic_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_topic_label.add_theme_font_size_override("font_size", 8)
	_topic_label.add_theme_color_override("font_color", Color(0.75, 0.75, 0.8))
	vbox.add_child(_topic_label)

	_stars_label = Label.new()
	_stars_label.text = HOLLOW_STAR + " " + HOLLOW_STAR + " " + HOLLOW_STAR
	_stars_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_stars_label.add_theme_font_size_override("font_size", 20)
	_stars_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2))
	vbox.add_child(_stars_label)

	_new_best_label = Label.new()
	_new_best_label.text = "NEW BEST!"
	_new_best_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_new_best_label.add_theme_font_size_override("font_size", 9)
	_new_best_label.add_theme_color_override("font_color", Color(0.4, 1.0, 0.5))
	_new_best_label.visible = false
	vbox.add_child(_new_best_label)

	var stats_panel_bg := StyleBoxFlat.new()
	stats_panel_bg.bg_color = Color(0, 0, 0, 0.4)
	stats_panel_bg.content_margin_left = 9
	stats_panel_bg.content_margin_right = 9
	stats_panel_bg.content_margin_top = 6
	stats_panel_bg.content_margin_bottom = 6
	stats_panel_bg.corner_radius_top_left = 4
	stats_panel_bg.corner_radius_top_right = 4
	stats_panel_bg.corner_radius_bottom_left = 4
	stats_panel_bg.corner_radius_bottom_right = 4

	var stats_panel := PanelContainer.new()
	stats_panel.add_theme_stylebox_override("panel", stats_panel_bg)
	vbox.add_child(stats_panel)

	var stats_grid := GridContainer.new()
	stats_grid.columns = 2
	stats_grid.add_theme_constant_override("h_separation", 16)
	stats_grid.add_theme_constant_override("v_separation", 2)
	stats_panel.add_child(stats_grid)

	_time_value = _add_stat_row(stats_grid, "Time")
	_correct_value = _add_stat_row(stats_grid, "Correct")
	_wrong_value = _add_stat_row(stats_grid, "Wrong")
	_enemies_value = _add_stat_row(stats_grid, "Enemies defeated")
	_deaths_value = _add_stat_row(stats_grid, "Deaths")

	_continue_button = Button.new()
	_continue_button.text = "Continue"
	_continue_button.custom_minimum_size.y = 22
	_continue_button.add_theme_font_size_override("font_size", 10)
	_continue_button.pressed.connect(_on_continue_pressed)
	vbox.add_child(_continue_button)

func _add_stat_row(grid : GridContainer, label_text : String) -> Label:
	var name_label := Label.new()
	name_label.text = label_text
	name_label.add_theme_font_size_override("font_size", 9)
	name_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.85))
	grid.add_child(name_label)

	var value_label := Label.new()
	value_label.text = "-"
	value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	value_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	value_label.add_theme_font_size_override("font_size", 9)
	value_label.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0))
	grid.add_child(value_label)
	return value_label

func setup(stats : Dictionary):
	var correct : int = stats.get("correct", 0)
	var total : int = stats.get("total", 0)
	var deaths : int = stats.get("deaths", 0)
	var enemies : int = stats.get("enemies_defeated", 0)
	var elapsed : float = stats.get("elapsed", 0.0)
	var topic_id : int = stats.get("topic_id", Globals.current_topic)

	var stars : int = _compute_stars(correct, total, deaths)
	var wrong : int = max(0, total - correct)

	_topic_label.text = QuestionBank.topic_names.get(topic_id, "")
	_stars_label.text = _render_stars(stars)
	_time_value.text = _format_time(elapsed)
	_correct_value.text = "%d / %d" % [correct, total]
	_wrong_value.text = "%d" % wrong
	_enemies_value.text = "%d" % enemies
	_deaths_value.text = "%d" % deaths

	var is_new_best : bool = Globals.record_stars(topic_id, stars)
	_new_best_label.visible = is_new_best

	_continue_button.grab_focus.call_deferred()

func _compute_stars(correct : int, total : int, deaths : int) -> int:
	var accuracy : float = float(correct) / float(max(total, 1))
	if accuracy >= 0.9 and deaths <= 1:
		return 3
	if accuracy >= 0.7 and deaths <= 3:
		return 2
	return 1

func _render_stars(stars : int) -> String:
	var out := ""
	for i in 3:
		if i > 0:
			out += "  "
		out += FILLED_STAR if i < stars else HOLLOW_STAR
	return out

func _format_time(seconds : float) -> String:
	var total_seconds : int = int(seconds)
	var m : int = total_seconds / 60
	var s : int = total_seconds % 60
	return "%d:%02d" % [m, s]

func _on_continue_pressed():
	continue_pressed.emit()
