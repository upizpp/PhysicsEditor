extends ElectricField2D
class_name MatrixElectricField2D

export var size := Vector2(128, 128) setget set_size

func set_size(v: Vector2) -> void:
	size = v
	if not shape:
		yield(self, "ready")
	shape.scale = v
	arrows.size = size
	light.scale = v
	update()

onready var shape: CollisionShape2D = $CollisionShape2D
onready var light: Light2D = $Light2D

func get_collision_shape() -> CollisionShape2D:
	return shape

func _draw() -> void:
	draw_rect(Rect2(-size * 0.5, size), Color.snow, false)
	var s := size - Vector2(2, 2)
	draw_rect(Rect2(-s * 0.5, s), Color.black, false, 1.5, true)
	arrows.update()
