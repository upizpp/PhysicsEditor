extends Node2D
class_name Arrows

const Interval = 24.0
const LineColor = Color(0, 0, 0, 0.5)

export var size: Vector2 = Vector2(128, 128)
export var direction_degrees: float = 0.0
export var arrow_centered := false

func _ready() -> void:
	material = CanvasItemMaterial.new()
	material.light_mode = CanvasItemMaterial.LIGHT_MODE_LIGHT_ONLY

func draw_arrow(begin: Vector2, end: Vector2) -> void:
	draw_line(begin, end, LineColor, 2.0, true)
	var v := (begin - end).normalized() * 12.0
	var p: Vector2
	if arrow_centered:
		p = (begin + end) / 2.0
	else:
		p = end
	draw_line(p + v.rotated(PI / 6.0), p, LineColor,  1.5, true)
	draw_line(p + v.rotated(-PI / 6.0), p, LineColor,  1.5, true)

func draw_field(from: Vector2, direction: float) -> void:
	var to: Vector2
	var delta := size * 0.5 - from
	if is_zero_approx(direction) or is_equal_approx(direction, PI):
		to = from + Vector2.RIGHT * delta.x
	elif is_equal_approx(direction, PI / 2.0):
		to = from + Vector2.DOWN * delta.y
	else:
		to = from + Vector2.RIGHT.rotated(direction) * min(delta.y / sin(direction), delta.x / cos(direction))
	draw_arrow(from, to)

func _draw() -> void:
	var ix := Interval
	var iy := Interval
	var t := sin(deg2rad(direction_degrees))
	if not is_zero_approx(t):
		ix /= t
		for x in range(0.0, size.x + 1.0, ix):
			draw_field(Vector2(x, 0.0) - size * 0.5, deg2rad(direction_degrees))
	t = cos(deg2rad(direction_degrees))
	if not is_zero_approx(t):
		iy /= t
		for y in range(0.0, size.y + 1.0, iy):
			draw_field(Vector2(0.0, y) - size * 0.5, deg2rad(direction_degrees))
