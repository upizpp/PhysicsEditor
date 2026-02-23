tool
extends Node2D


func _ready() -> void:
	update()

func _draw() -> void:
	draw_circle(Vector2.ZERO, 100.0, Color.whitesmoke)
