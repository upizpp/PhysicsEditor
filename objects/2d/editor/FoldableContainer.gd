extends PanelContainer
class_name FoldableContainer

signal remove(property)

export var group_name: String setget set_group_name

onready var add_edit: LineEdit = $VBoxContainer/PanelContainer/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer/LineEdit
onready var container: VBoxContainer = $VBoxContainer/PanelContainer/VBoxContainer/HBoxContainer/VBoxContainer/Children
onready var panel_container: PanelContainer = $VBoxContainer/PanelContainer

var object: Dictionary = {}
var bind: Node2D = null

func set_group_name(v: String) -> void:
	group_name = v
	if not is_inside_tree():
		yield(self, "ready")
	$VBoxContainer/HBoxContainer1/Label.text = v

func unfold():
	$VBoxContainer/HBoxContainer1/CheckButton.pressed = true

func add(property: String = "") -> VariableEdit:
	var edit := preload("res://objects/2d/editor/VariableEdit.tscn").instance()
	container.add_child(edit)
	edit.property = property
	if property.empty():
		edit.rename()
	else:
		if not object.has(property):
			object[property] = ""
		edit.connect("changed", self, "_on_property_changed", [property])
		edit.connect("remove", self, "_on_property_removed")
		if property == "size":
			bind.connect("resize", edit, "change_content")
		elif property == "position":
			bind.connect("move", edit, "change_content")
	return edit as VariableEdit

func get_data() -> Dictionary:
	var res := {}
	for child in container.get_children():
		if child is VariableEdit:
			res[child.property] = child.get_value()
		else:
			res[child.group_name] = child.get_data()
	return res

func remove() -> void:
	queue_free()
	emit_signal("remove", group_name)

func _on_property_removed(property: String):
	object.erase(property)

func _on_property_changed(new_value: String, property: String) -> void:
	var arr = Global.eval_property(new_value)
	if arr[0] == OK:
		object[property] = new_value
		bind.set(property, arr[1])

func _on_Label_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == BUTTON_RIGHT and event.pressed:
		remove()

func _on_CheckButton_toggled(button_pressed: bool) -> void:
	panel_container.visible = button_pressed

func _on_AddButton_pressed() -> void:
	add(add_edit.text)
	add_edit.clear()

func _on_AddEdit_text_entered(new_text: String) -> void:
	add(add_edit.text)
	add_edit.clear()
