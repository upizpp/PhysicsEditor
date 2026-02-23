extends Area2D
class_name Baffle2D

var negative: bool = false

func _ready() -> void:
	connect("area_entered", self, "_on_area_entered")
	connect("area_exited", self, "_on_area_exited")


func get_normal(obj: PhysicsObject2D) -> Vector2:
	return Vector2.ZERO


func _on_area_entered(area: Area2D):
	if not negative and area is PhysicsObject2D:
		area.velocity -= area.velocity.project(get_normal(area)) * 2.0

func _on_area_exited(area: Area2D):
	if negative and area is PhysicsObject2D:
		area.velocity -= area.velocity.project(get_normal(area)) * 2.0
