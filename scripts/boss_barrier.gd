extends Node2D
class_name BossBarrier

@export var radius_x : float = 28.0
@export var radius_y : float = 44.0
@export var fill_color : Color = Color(0.25, 0.55, 1.0, 0.18)
@export var stroke_color : Color = Color(0.45, 0.85, 1.0, 0.85)
@export var glow_color : Color = Color(0.7, 0.95, 1.0, 0.55)
@export var pulse_speed : float = 2.5
@export var pulse_amplitude : float = 0.06
@export var segments : int = 36

var _t : float = 0.0

func _ready():
	z_index = 5

func _process(delta : float):
	_t += delta * pulse_speed
	queue_redraw()

func _draw():
	var pulse : float = 1.0 + pulse_amplitude * sin(_t)
	var rx : float = radius_x * pulse
	var ry : float = radius_y * pulse
	var pts : PackedVector2Array = PackedVector2Array()
	for i in segments + 1:
		var a : float = TAU * float(i) / float(segments)
		pts.append(Vector2(cos(a) * rx, sin(a) * ry))

	# translucent fill (bubble interior)
	var fill_alpha : float = fill_color.a * (0.85 + 0.15 * sin(_t * 0.6))
	var fc : Color = Color(fill_color.r, fill_color.g, fill_color.b, fill_alpha)
	draw_colored_polygon(pts, fc)

	# bright outer stroke
	for i in segments:
		draw_line(pts[i], pts[i + 1], stroke_color, 2.0)

	# inner glow ring
	var glow_alpha : float = glow_color.a * (0.5 + 0.5 * (0.5 + 0.5 * sin(_t * 1.4)))
	var gc : Color = Color(glow_color.r, glow_color.g, glow_color.b, glow_alpha)
	for i in segments:
		var p0 : Vector2 = pts[i] * 0.88
		var p1 : Vector2 = pts[i + 1] * 0.88
		draw_line(p0, p1, gc, 1.0)
