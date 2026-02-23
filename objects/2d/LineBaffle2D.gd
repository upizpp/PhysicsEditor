extends Baffle2D
class_name LineBaffle2D

const Width = 12.0

export var length := 128.0 setget set_length

var size := Vector2(length, Width)

func set_length(v: float):
	length = v
	size = Vector2(length, Width)
	if not shape:
		yield(self, "ready")
	shape.scale = size
	update()

onready var shape: CollisionShape2D = $CollisionShape2D

func get_normal(obj: PhysicsObject2D) -> Vector2:
	return Vector2.UP.rotated(rotation)

func _draw() -> void:
	draw_rect(Rect2(-size * 0.5, size), Color.snow, false)
	draw_rect(Rect2(-size * 0.5, size), Color.black, false, 1.5, true)
