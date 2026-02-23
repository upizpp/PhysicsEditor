extends Viewport
class_name ViewportCircle


export var radius: float = 128.0 setget set_radius


var canvas := Node2D.new()

func _ready() -> void:
	transparent_bg = true
	add_child(canvas)
	canvas.connect("draw", self, "_draw")

func set_radius(v: float):
	radius = v
	canvas.update()

func _draw() -> void:
	canvas.draw_circle(Vector2.ONE * radius, radius, Color.white)
