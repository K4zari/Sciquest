extends CanvasLayer

## Top-of-screen dialog box shown whenever the player steps into an InfoBoard's
## trigger area. Replaces the old in-world floating label (which sat right on
## top of the player and was hard to read) with a readable, portrait-fronted
## box that types the board's text out like a real character speaking it.

const TYPE_INTERVAL : float = 0.022
const FADE_TIME : float = 0.2
const PORTRAIT_FRAME_SIZE : int = 28

var _box : PanelContainer
var _portrait : TextureRect
var _label : RichTextLabel

var _full_text : String = ""
var _typing : bool = false
var _char_timer : float = 0.0
var _active_board : Node = null

func _ready():
	layer = 20
	visible = false
	_build_ui()
	_apply_portrait()

func is_active() -> bool:
	return _active_board != null

## Immediately dismiss any open dialog, regardless of which board opened it.
## Used when a battle starts so a board the player was standing on can't leave
## its box layered over the quiz UI.
func force_hide():
	_active_board = null
	_typing = false
	visible = false
	if _box:
		_box.modulate.a = 0.0

func _build_ui():
	var panel_bg := StyleBoxFlat.new()
	panel_bg.bg_color = Color(0, 0, 0, 0.8)
	panel_bg.border_color = Color(0.85, 0.75, 0.4, 0.9)
	panel_bg.border_width_left = 2
	panel_bg.border_width_right = 2
	panel_bg.border_width_top = 2
	panel_bg.border_width_bottom = 2
	panel_bg.corner_radius_top_left = 6
	panel_bg.corner_radius_top_right = 6
	panel_bg.corner_radius_bottom_left = 6
	panel_bg.corner_radius_bottom_right = 6
	panel_bg.content_margin_left = 10
	panel_bg.content_margin_right = 10
	panel_bg.content_margin_top = 8
	panel_bg.content_margin_bottom = 8

	_box = PanelContainer.new()
	_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_box.add_theme_stylebox_override("panel", panel_bg)
	add_child(_box)
	_box.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE, Control.PRESET_MODE_MINSIZE)
	_box.offset_left = 36
	_box.offset_right = -36
	_box.offset_top = 12
	_box.custom_minimum_size.y = 60

	var row := HBoxContainer.new()
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_theme_constant_override("separation", 10)
	_box.add_child(row)

	_portrait = TextureRect.new()
	_portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_portrait.custom_minimum_size = Vector2(40, 40)
	_portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_portrait.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	row.add_child(_portrait)

	_label = RichTextLabel.new()
	_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_label.bbcode_enabled = true
	_label.fit_content = true
	_label.scroll_active = false
	_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_label.add_theme_font_size_override("normal_font_size", 12)
	_label.add_theme_color_override("default_color", Color(1, 1, 0.85))
	row.add_child(_label)

func _process(delta):
	if not _typing:
		return
	_char_timer += delta
	while _typing and _char_timer >= TYPE_INTERVAL:
		_char_timer -= TYPE_INTERVAL
		_label.visible_characters += 1
		if _label.visible_characters >= _label.get_total_character_count():
			_typing = false

## Called by an InfoBoard when the player enters its trigger area.
func show_dialog(board: Node, text: String):
	_active_board = board
	_full_text = text
	_label.text = text
	_label.visible_characters = 0
	_char_timer = 0.0
	_typing = true
	visible = true
	_box.modulate.a = 0.0
	var tw := create_tween()
	tw.tween_property(_box, "modulate:a", 1.0, FADE_TIME)

## Called by an InfoBoard when the player leaves its trigger area. Guarded by
## `board` so a board the player already walked away from can't dismiss a
## dialog that a different, newly-entered board just opened moments later.
func hide_dialog(board: Node):
	if _active_board != board:
		return
	_active_board = null
	_typing = false
	var tw := create_tween()
	tw.tween_property(_box, "modulate:a", 0.0, FADE_TIME)
	tw.tween_callback(func ():
		if _active_board == null:
			visible = false
	)

## Crops the player's chosen face sheet down to its first (neutral) frame so
## the box always shows whichever character — Ahmad or Aishah — is "speaking".
func _apply_portrait():
	var tex : Texture2D = load(Globals.get_player_face_path())
	if tex == null:
		return
	var atlas := AtlasTexture.new()
	atlas.atlas = tex
	atlas.region = Rect2(0, 0, PORTRAIT_FRAME_SIZE, PORTRAIT_FRAME_SIZE)
	_portrait.texture = atlas
