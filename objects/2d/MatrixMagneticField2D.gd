extends MagneticField2D
class_name MatrixMagneticField2D

const Interval = 32.0
const Margin = Vector2(16.0, 16.0)

export var size := Vector2(128, 128) setget set_size

func set_size(v: Vector2) -> void:
	size = v
	if not shape:
		yield(self, "ready")
	shape.scale = v
	update()


onready var shape: CollisionShape2D = $CollisionShape2D


func get_collision_shape() -> CollisionShape2D:
	return shape

func _draw() -> void:
	draw_rect(Rect2(-size * 0.5, size), Color.snow, false)
	draw_rect(Rect2(-size * 0.5, size), Color.black, false, 1.5, true)
	var texture: Texture = preload("res://assets/textures/cross.png") if direction == DIR.CROSS else preload("res://assets/textures/dot.png")
	for x in range(Margin.x, size.x - Margin.x + 1, Interval):
		for y in range(Margin.y, size.y - Margin.y + 1, Interval):
			draw_texture(texture, Vector2(x, y) - size /  2.0)
