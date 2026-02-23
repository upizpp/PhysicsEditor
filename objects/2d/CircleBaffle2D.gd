extends Baffle2D
class_name CircleBaffle2D

export var radius: float = 128.0 setget set_radius

func set_radius(v: float):
	radius = v
	if not shape:
		yield(self, "ready")
	shape.scale = Vector2.ONE * radius
	update()

onready var shape: CollisionShape2D = $CollisionShape2D

func _init() -> void:
	negative = true

func _draw() -> void:
	draw_circle(Vector2.ZERO, radius, Color(1, 0.980392, 0.980392, 0.25))
	draw_arc(Vector2.ZERO, radius, 0.0, 2 * PI, 64, Color.black, 1.5, true)

func get_normal(obj: PhysicsObject2D) -> Vector2:
	return obj.global_position - global_position
