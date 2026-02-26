extends Line2D
class_name TrailTracker2D

const MaxPoints = 1800

export var target: NodePath setget set_target
export var period: int = 3

var target_node: Node2D

func set_target(v: NodePath) -> void:
	target = v
	if not is_inside_tree():
		yield(self, "ready")
	target_node = get_node(v)

func _init() -> void:
	width = 2.0
	z_index += 2
	antialiased = true

func _process(delta: float) -> void:
	if not target_node:
		return
	if get_tree().get_frame() % period == 0:
		add_point(target_node.position)
		if get_point_count() > MaxPoints:
			var copy := Line2D.new() # 防止循环引用
			copy.points = points
			copy.width = width
			copy.z_index = z_index
			copy.default_color = default_color
			get_parent().add_child(copy)
			var last := points[points.size() - 1]
			clear_points()
			add_point(last)
