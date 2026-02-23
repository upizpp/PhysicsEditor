extends MagneticField2D
class_name CircleMagneticField2D


export var radius: float = 128.0 setget set_radius

func set_radius(v: float):
	radius = v
	if not shape:
		yield(self, "ready")
	shape.scale = Vector2.ONE * radius
	viewport.radius = radius
	viewport.size = Vector2.ONE * radius * 2.0
	viewport.render_target_update_mode = Viewport.UPDATE_ONCE
	update()


onready var shape: CollisionShape2D = $CollisionShape2D
onready var viewport: ViewportCircle = $ViewportCircle
onready var points: Node2D = $Points2D

func get_collision_shape() -> CollisionShape2D:
	return shape

func _draw() -> void:
	draw_circle(Vector2.ZERO, radius, Color.snow)
	draw_arc(Vector2.ZERO, radius, 0.0, 2 * PI, int(radius / 2) + 32, Color.black, 1.5, true)
	points.size = Vector2.ONE * radius * 2.0
	points.texture = preload("res://assets/textures/cross.png") if direction == DIR.CROSS else preload("res://assets/textures/dot.png")
