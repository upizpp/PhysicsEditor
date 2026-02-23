extends Field2D
class_name ElectricField2D


export var strength := 100.0
export(float, 0.0, 360.0, 0.1) var direction_degrees := 0.0 setget set_dir

onready var arrows: Node2D = $Arrows

func set_dir(v: float) -> void:
	direction_degrees = fmod(v, 360.0)
	if not is_inside_tree():
		yield(self, "ready")
	while direction_degrees > 90.0:
		direction_degrees -= 90.0
		arrows.rotation_degrees += 90.0
	arrows.direction_degrees = direction_degrees

func enforce(obj: PhysicsObject2D) -> void:
	var dir := deg2rad(direction_degrees + arrows.rotation_degrees)
	var electric_force := obj.charge * strength * Vector2.RIGHT.rotated(dir)
	obj.enforce(electric_force)
