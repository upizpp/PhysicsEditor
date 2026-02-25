extends Control

signal clicked(object)

onready var preview: Node2D = $Preview

func _ready() -> void:
	preview.update()

func _on_Preview_draw() -> void:
	preview.draw_rect(Rect2(Vector2.ZERO, Global.WindowSize), Color(194.0 / 255.0, 194.0 / 255.0,1.0), false)


var dragging: bool = false
var preview_position := Vector2.ZERO
var initial_position := Vector2.ZERO

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_RIGHT and get_global_rect().has_point(event.position):
		dragging = true
		preview_position = preview.position
		initial_position = event.position
	if dragging and event is InputEventMouseButton and not event.pressed and event.button_index == BUTTON_RIGHT:
		dragging = false
	if dragging and event is InputEventMouseMotion:
		preview.position = preview_position - (initial_position - event.position)
	if event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_WHEEL_DOWN and get_global_rect().has_point(event.position):
		if preview.scale.x > 0.05:
			preview.scale -= Vector2.ONE * 0.05
	if event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_WHEEL_UP and get_global_rect().has_point(event.position):
		preview.scale += Vector2.ONE * 0.05

func clear() -> void:
	for c in preview.get_children():
		c.queue_free()

func load_scene(scene: Array) -> void:
	clear()
	for obj in scene:
		create_object(obj)

func create_object(object: Dictionary) -> void:
	if object.has("type") and object["type"] == "object":
		var obj := preload("res://objects/2d/editor/CircleEditor.tscn").instance()
		if object.has("properties"):
			for property in object["properties"]:
				var value = object["properties"][property]
				if value is String:
					value = Global.eval_property(value)[1]
				obj.set(property, value)
		obj.scaleable = false
		obj.radius = 8
		obj.bind = object
		obj.connect("clicked", self, "_on_object_clicked", [object])
		preview.add_child(obj)
		object["__bind__"] = obj
	if object.has("shape"):
		if object["shape"] == "matrix":
			var obj := preload("res://objects/2d/editor/MatrixEditor.tscn").instance()
			if object.has("type") and object["type"] == "baffle":
				obj.lock_y = LineBaffle2D.Width
			if object.has("properties"):
				for property in object["properties"]:
					var value = object["properties"][property]
					if value is String:
						value = Global.eval_property(value)[1]
					obj.set(property, value)
			obj.bind = object
			obj.connect("clicked", self, "_on_object_clicked", [object])
			preview.add_child(obj)
			object["__bind__"] = obj
		elif object["shape"] == "circle":
			var obj := preload("res://objects/2d/editor/CircleEditor.tscn").instance()
			if object.has("properties"):
				for property in object["properties"]:
					var value = object["properties"][property]
					if value is String:
						value = Global.eval_property(value)[1]
					obj.set(property, value)
			obj.bind = object
			obj.connect("clicked", self, "_on_object_clicked", [object])
			preview.add_child(obj)
			object["__bind__"] = obj

func _on_object_clicked(object: Dictionary):
	emit_signal("clicked", object)
