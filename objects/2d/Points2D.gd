extends Node2D
class_name Points2D

export var margin: Vector2 = Vector2.ZERO
export var size: Vector2 = Vector2.ZERO
export var interval: float = 32.0
export var texture: Texture setget set_texture

func set_texture(v: Texture):
	texture = v
	update()

func _ready() -> void:
	material = CanvasItemMaterial.new()
	material.light_mode = CanvasItemMaterial.LIGHT_MODE_LIGHT_ONLY

func _draw() -> void:
	for x in range(margin.x, size.x - margin.x + 1, interval):
		for y in range(margin.y, size.y - margin.y + 1, interval):
			draw_texture(texture, Vector2(x, y) - size /  2.0)
