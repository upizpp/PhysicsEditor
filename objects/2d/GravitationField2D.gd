extends Field2D
class_name GravitationField2D

export var field_source_path: NodePath setget set_field_source

func set_field_source(v: NodePath):
	field_source_path = v
	if not is_inside_tree():
		yield(self, "ready")
	if v.is_empty():
		field_source = get_parent()
	else:
		field_source = get_node(v)

var field_source: PhysicsObject2D

func enforce(obj: PhysicsObject2D) -> void:
	if obj.no_gravitation:
		return
	if not field_source:
		field_source = get_parent()
	if obj == field_source:
		return
	var G := 6.674184e3 / (Global.DecelerationRatio * Global.DecelerationRatio)
	var r := field_source.global_position - obj.global_position
	if r.length_squared() < 100.0:
		return
	var gravitation := (
		r.normalized() *
		G * field_source.mass * obj.mass /
		r.length_squared()
	)
	obj.enforce(gravitation)

func is_colliding(obj: PhysicsObject2D) -> bool:
	return true
