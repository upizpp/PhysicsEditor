tool
extends PanelContainer
class_name VariableEdit

signal remove(property)
signal changed(new_value)
signal variable_renamed(new_name)

export var property: String setget set_property
export var value: String setget set_value
export var editable: bool = true

onready var label: Label = $HBoxContainer/Label
onready var line_edit: LineEdit = $HBoxContainer/LineEdit
onready var button: Button = $HBoxContainer/Label/Button
onready var property_edit: LineEdit = $HBoxContainer/Label/Property

func set_value(v: String) -> void:
	value = v
	if not is_inside_tree():
		yield(self, "ready")
	line_edit.text = v

func get_value() -> String:
	if not is_inside_tree():
		yield(self, "ready")
	return line_edit.text

func set_property(v: String) -> void:
	property = v
	if not is_inside_tree():
		yield(self, "ready")
	label.text = v

func rename() -> void:
	button.hide()
	property_edit.text = property
	property_edit.show()
	property_edit.select_all()
	property_edit.grab_focus()

func finish_rename(what: String) -> void:
	if what.empty():
		queue_free()
	emit_signal("variable_renamed", what)
	self.property = what
	property_edit.hide()
	button.show()

func change_content(what) -> void:
	self.value = var2str(what)

func _on_Button_pressed() -> void:
	if editable:
		rename()

func _on_Property_text_entered(new_text: String) -> void:
	finish_rename(new_text)

func _on_Property_focus_exited() -> void:
	finish_rename(property_edit.text)

func _on_Button_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == BUTTON_RIGHT and event.pressed:
		emit_signal("remove", property)
		queue_free()

func _on_LineEdit_text_changed(new_text: String) -> void:
	emit_signal("changed", new_text)
