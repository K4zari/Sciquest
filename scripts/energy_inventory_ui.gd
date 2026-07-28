extends CanvasLayer
## Popup that lets the player pick a collected energy orb to feed a generator,
## plus a small always-on indicator of orbs collected so far (Topic 7 puzzle).
## Built entirely in GDScript, following the scripts/battle_ui.gd pattern.

const ORB_SHEET_PATH := "res://graphics/topic_7_energy/fuel_orbs_sheet.png"
const ORB_FRAMES := 5
const ORB_NAMES := ["Solar", "Water", "Wind", "Coal", "Biomass"]

var _orb_sheet : Texture2D

var _root : Control            # full-screen popup container (hidden by default)
var _title : Label
var _feedback : Label
var _orb_row : HBoxContainer
var _cancel_btn : Button

var _indicator_panel : PanelContainer  # the corner strip container (hidden in battle)
var _indicator_row : HBoxContainer  # persistent collected-orbs strip
var _current_generator : Node = null
var _popup_open : bool = false
## Frame the popup opened on, so the same button press that opens it (E / B —
## which doubles as ui_cancel on a controller) doesn't immediately close it.
var _open_frame : int = -1

func _ready() -> void:
	layer = 20
	_orb_sheet = load(ORB_SHEET_PATH)
	_build_indicator()
	_build_popup()
	_refresh_indicator()
	EventBus.energy_select_requested.connect(_on_select_requested)
	EventBus.energy_collected.connect(func(_s): _refresh_indicator())
	EventBus.energy_consumed.connect(func(_s): _refresh_indicator())

func _process(_delta : float) -> void:
	# Keep the orb strip out of the way during quiz battles (it sits above the
	# battle UI), while the selection popup is open, and while an info-board
	# dialog is on screen (it overlaps the dialog box in the top-right corner).
	if _indicator_panel:
		_indicator_panel.visible = not BattleManager.is_active() and not DialogManager.is_active() and not _popup_open

# ── styling helpers ──────────────────────────────────────────────────────────
func _panel_style() -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0, 0, 0, 0.82)
	sb.border_color = Color(0.8, 0.7, 0.3, 0.9)
	sb.border_width_left = 2
	sb.border_width_right = 2
	sb.border_width_top = 2
	sb.border_width_bottom = 2
	sb.corner_radius_top_left = 4
	sb.corner_radius_top_right = 4
	sb.corner_radius_bottom_left = 4
	sb.corner_radius_bottom_right = 4
	sb.content_margin_left = 14
	sb.content_margin_right = 14
	sb.content_margin_top = 12
	sb.content_margin_bottom = 12
	return sb

func _button_style(color : Color, focus : bool = false) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = color
	sb.corner_radius_top_left = 4
	sb.corner_radius_top_right = 4
	sb.corner_radius_bottom_left = 4
	sb.corner_radius_bottom_right = 4
	sb.content_margin_left = 8
	sb.content_margin_right = 8
	sb.content_margin_top = 6
	sb.content_margin_bottom = 6
	if focus:
		sb.border_width_left = 2
		sb.border_width_right = 2
		sb.border_width_top = 2
		sb.border_width_bottom = 2
		sb.border_color = Color.WHITE
	return sb

func _orb_icon(source : int) -> AtlasTexture:
	var at := AtlasTexture.new()
	at.atlas = _orb_sheet
	var fw : float = float(_orb_sheet.get_width()) / float(ORB_FRAMES)
	var h : float = float(_orb_sheet.get_height())
	at.region = Rect2(source * fw, 0, fw, h)
	return at

# ── persistent indicator ─────────────────────────────────────────────────────
func _build_indicator() -> void:
	# Pinned to the top-right corner, sizing to its content and growing leftward.
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _panel_style())
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.anchor_left = 1.0
	panel.anchor_right = 1.0
	panel.anchor_top = 0.0
	panel.anchor_bottom = 0.0
	panel.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	panel.grow_vertical = Control.GROW_DIRECTION_END
	panel.offset_right = -8.0
	panel.offset_top = 8.0
	add_child(panel)
	_indicator_panel = panel

	_indicator_row = HBoxContainer.new()
	_indicator_row.add_theme_constant_override("separation", 6)
	panel.add_child(_indicator_row)

func _refresh_indicator() -> void:
	if _indicator_row == null:
		return
	for c in _indicator_row.get_children():
		c.queue_free()
	var title := Label.new()
	title.text = "Energy:"
	title.add_theme_font_size_override("font_size", 10)
	title.add_theme_color_override("font_color", Color(0.85, 0.78, 0.4))
	_indicator_row.add_child(title)
	if Globals.energy_orbs.is_empty():
		var none := Label.new()
		none.text = "—"
		none.add_theme_font_size_override("font_size", 10)
		none.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
		_indicator_row.add_child(none)
		return
	for source in Globals.energy_orbs:
		var tex := TextureRect.new()
		tex.texture = _orb_icon(int(source))
		tex.custom_minimum_size = Vector2(24, 24)
		tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		tex.tooltip_text = ORB_NAMES[int(source)]
		_indicator_row.add_child(tex)

# ── selection popup ──────────────────────────────────────────────────────────
func _build_popup() -> void:
	_root = Control.new()
	_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_root.mouse_filter = Control.MOUSE_FILTER_STOP
	_root.visible = false
	add_child(_root)

	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.55)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	_root.add_child(dim)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_root.add_child(center)

	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _panel_style())
	panel.custom_minimum_size = Vector2(360, 0)
	center.add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	panel.add_child(vbox)

	_title = Label.new()
	_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title.add_theme_font_size_override("font_size", 13)
	_title.add_theme_color_override("font_color", Color(0.95, 0.88, 0.55))
	vbox.add_child(_title)

	_feedback = Label.new()
	_feedback.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_feedback.add_theme_font_size_override("font_size", 11)
	_feedback.visible = false
	vbox.add_child(_feedback)

	_orb_row = HBoxContainer.new()
	_orb_row.alignment = BoxContainer.ALIGNMENT_CENTER
	_orb_row.add_theme_constant_override("separation", 10)
	vbox.add_child(_orb_row)

	_cancel_btn = Button.new()
	_cancel_btn.text = "Cancel"
	_cancel_btn.custom_minimum_size.y = 26
	_cancel_btn.add_theme_font_size_override("font_size", 11)
	_cancel_btn.add_theme_color_override("font_color", Color.WHITE)
	_cancel_btn.add_theme_stylebox_override("normal", _button_style(Color("#555555")))
	_cancel_btn.add_theme_stylebox_override("hover", _button_style(Color("#666666")))
	_cancel_btn.add_theme_stylebox_override("pressed", _button_style(Color("#444444")))
	_cancel_btn.add_theme_stylebox_override("focus", _button_style(Color("#555555"), true))
	_cancel_btn.pressed.connect(_close)
	vbox.add_child(_cancel_btn)

func _on_select_requested(generator : Node) -> void:
	if _popup_open:
		return
	_current_generator = generator
	_popup_open = true
	_open_frame = Engine.get_process_frames()
	if Globals.player:
		Globals.player.frozen = true
	var gen_name : String = generator.display_name() if generator.has_method("display_name") else "Generator"
	_title.text = "Insert energy for:\n%s" % gen_name
	_feedback.visible = false
	_populate_orbs()
	_root.visible = true
	_focus_first_orb()

## Put keyboard/controller focus on the first orb button so the popup is fully
## navigable without a mouse (arrow keys / D-pad to move, A / Enter to pick).
func _focus_first_orb() -> void:
	for col in _orb_row.get_children():
		for n in col.get_children():
			if n is Button:
				n.grab_focus.call_deferred()
				return
	_cancel_btn.grab_focus.call_deferred()

func _populate_orbs() -> void:
	# Remove old orb buttons from the tree immediately (not just queue_free, which
	# defers deletion to frame end). Otherwise _focus_first_orb() — called right
	# after this on a wrong pick — would still see the stale columns in
	# get_children() and grab focus on a button that's about to be freed, leaving
	# nothing focused and breaking controller navigation.
	for c in _orb_row.get_children():
		_orb_row.remove_child(c)
		c.queue_free()
	if Globals.energy_orbs.is_empty():
		var empty := Label.new()
		empty.text = "No energy collected yet."
		empty.add_theme_font_size_override("font_size", 11)
		empty.add_theme_color_override("font_color", Color(0.8, 0.6, 0.6))
		_orb_row.add_child(empty)
		return
	for source in Globals.energy_orbs:
		_orb_row.add_child(_make_orb_option(int(source)))

## An orb choice = icon above a labelled button (avoids version-specific Button
## icon-alignment APIs). Both the icon and the button trigger the selection.
func _make_orb_option(source : int) -> Control:
	var vbox := VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 4)

	var icon := TextureRect.new()
	icon.texture = _orb_icon(source)
	icon.custom_minimum_size = Vector2(48, 48)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	vbox.add_child(icon)

	var btn := Button.new()
	btn.custom_minimum_size = Vector2(76, 26)
	btn.text = ORB_NAMES[source]
	btn.add_theme_font_size_override("font_size", 11)
	btn.add_theme_color_override("font_color", Color.WHITE)
	var base := Color("#29608f")
	btn.add_theme_stylebox_override("normal", _button_style(base))
	btn.add_theme_stylebox_override("hover", _button_style(base.lightened(0.15)))
	btn.add_theme_stylebox_override("pressed", _button_style(base.darkened(0.2)))
	btn.add_theme_stylebox_override("focus", _button_style(base, true))
	btn.pressed.connect(func(): _on_pick(source))
	vbox.add_child(btn)
	return vbox

func _on_pick(source : int) -> void:
	if _current_generator == null or not is_instance_valid(_current_generator):
		_close()
		return
	var accepted : bool = _current_generator.try_energy(source)
	if accepted:
		_close()
	else:
		_feedback.text = "%s is not compatible — try another." % ORB_NAMES[source]
		_feedback.add_theme_color_override("font_color", Color(1.0, 0.45, 0.4))
		_feedback.visible = true
		_populate_orbs()
		_focus_first_orb()

func _close() -> void:
	_popup_open = false
	_root.visible = false
	_current_generator = null
	if Globals.player:
		Globals.player.frozen = false

func _input(event : InputEvent) -> void:
	if not _popup_open:
		return
	# Ignore the very button press that opened the popup (E / B also maps to
	# ui_cancel on a controller), otherwise it would close on the same frame.
	if Engine.get_process_frames() == _open_frame:
		return
	# Cancel with Esc (keyboard) or B / ui_cancel (controller).
	if event.is_action_pressed("ui_cancel"):
		_close()
		get_viewport().set_input_as_handled()
