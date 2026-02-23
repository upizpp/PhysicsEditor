extends Area2D
class_name Field2D


func _init() -> void:
	add_to_group("fields")


func enforce(obj: PhysicsObject2D) -> void:
	pass

func get_collision_shape() -> CollisionShape2D:
	return null

func is_colliding(obj: PhysicsObject2D) -> bool:
	var s := get_collision_shape()
	return s.shape.collide(s.get_global_transform(), obj.shape.shape, obj.get_global_transform())
