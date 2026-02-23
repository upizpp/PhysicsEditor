extends Field2D
class_name MagneticField2D

enum DIR{
	CROSS,
	DOT
}

export(DIR) var direction: int = DIR.CROSS
export var strength: float = 1.0


func enforce(obj: PhysicsObject2D) -> void:
	var dir := 1 if direction == 1 else -1
	var lorentz_force := (obj.charge * obj.velocity * strength).rotated(dir * PI / 2.0)
	obj.enforce(lorentz_force)
