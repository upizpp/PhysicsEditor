extends Node

onready var text: Control = $Text


func _ready() -> void:
	get_tree().set_screen_stretch(SceneTree.STRETCH_MODE_2D, SceneTree.STRETCH_ASPECT_KEEP, Global.WindowSize)
	load_scene(Global.target_file)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("return"):
		get_tree().change_scene("res://objects/2d/editor/Editor.tscn")

func load_scene(path: String) -> void:
	for c in get_children():
		if c != text:
			c.queue_free()
	
	var msg: String = Global.load_file(path)
	if not msg.empty():
		push_text(msg)
		return
	create(Global.editor_scene, Global.editor_variables)

const ObjectTypes = {
	"object": preload("res://objects/2d/PhysicsObject2D.tscn"),
	"matrix_magnetic": preload("res://objects/2d/MatrixMagneticField2D.tscn"),
	"circle_magnetic": preload("res://objects/2d/CircleMagneticField2D.tscn"),
	"matrix_electric": preload("res://objects/2d/MatrixElectricField2D.tscn"),
	"circle_electric": preload("res://objects/2d/CircleElectricField2D.tscn"),
	"matrix_baffle": preload("res://objects/2d/LineBaffle2D.tscn"),
	"circle_baffle": preload("res://objects/2d/CircleBaffle2D.tscn")
}
func create(scene: Array, variables: Dictionary):
	for o in scene:
		if not o is Dictionary:
			push_text("意外的object类型，期望为Dictionary。")
			return
		var data := o as Dictionary
		var object_key: String
		
		var type = read(data, "type", TYPE_STRING, "object")
		if type == null:
			return
		if data.has("shape"):
			var shape = read(data, "shape", TYPE_STRING, "object")
			if shape == null:
				return
			object_key = shape + "_" + type
		else:
			object_key = type
		
		var obj: Node
		if ClassDB.class_exists(object_key) and ClassDB.can_instance(object_key):
			obj = ClassDB.instance(object_key)
		elif ObjectTypes.has(object_key):
			obj = ObjectTypes[object_key].instance()
		else:
			push_text("未知场景类型%s。" % object_key)
			return
		
		add_child(obj)
		var expr = Expression.new()
		if data.has("properties"):
			if typeof(data["properties"]) != TYPE_DICTIONARY:
				push_text("意外的object类型，properties字段必须是Dictionary。")
				return null
			for property in data["properties"]:
				if property == "track":
					var tracker := TrailTracker2D.new()
					tracker.target = obj.get_path()
					add_child(tracker)
					if data["properties"][property] is String:
						var arg := Global.eval_property(data["properties"][property])
						if arg[0] != OK:
							continue
						data["properties"][property] = arg[1]
					for p in data["properties"][property]:
						tracker.set(p, data["properties"][property][p])
				elif property == "gravitation":
					var x := GravitationField2D.new()
					x.field_source_path = obj.get_path()
					obj.add_child(x)
				elif property == "coulomb":
					var x := CoulombFieldField2D.new()
					x.field_source_path = obj.get_path()
					obj.add_child(x)
				else:
					if data["properties"][property] is String:
						expr.parse(data["properties"][property], variables.keys())
						obj.set(property, expr.execute(variables.values()))
					else:
						obj.set(property, data["properties"][property])

func read(data: Dictionary, key: String, expected: int, type: String):
	if not data.has(key):
		push_text("意外的%s类型，必须要有%s字段。" % [type, key])
		return null
	if typeof(data[key]) != expected:
		push_text("意外的%s类型，%s字段必须是%s。" % [type, key, str(expected)])
		return null
	return data[key]

func push_text(txt: String) -> void:
	var label := Label.new()
	label.text = txt
	label.align = Label.ALIGN_CENTER
	label.valign = Label.VALIGN_CENTER
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.set("custom_colors/font_color", Color.black)
	label.set("custom_fonts/font", preload("res://assets/fonts/large.tres"))
	text.add_child(label)
