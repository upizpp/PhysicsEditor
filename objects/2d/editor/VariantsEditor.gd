extends PanelContainer

onready var variables_container: VBoxContainer = $ScrollContainer/VBoxContainer/PanelContainer/VBoxContainer

func load_variables(variables: Dictionary):
	for property in variables:
		var edit := preload("res://objects/2d/editor/VariableEdit.tscn").instance()
		edit.property = property
		edit.value = Global.to_editable(variables[property])
		edit.connect("remove", self, "_on_variable_remove")
		edit.connect("changed", self, "_on_variable_changed", [property])
		variables_container.add_child(edit)

func clear() -> void:
	for c in variables_container.get_children():
		c.queue_free()

func add() -> void:
	var edit := preload("res://objects/2d/editor/VariableEdit.tscn").instance()
	variables_container.add_child(edit)
	edit.rename()
	edit.connect("remove", self, "_on_variable_remove")
	edit.connect("variable_renamed", self, "_on_variable_renamed", [edit])

func get_variables() -> Dictionary:
	var res := {}
	for edit in variables_container.get_children():
		if edit is VariableEdit:
			res[edit.property] = edit.get_value()
	return res

func _on_variable_renamed(new_name: String, obj: VariableEdit) -> void:
	if obj.is_connected("changed", self, "_on_variable_changed"):
		obj.disconnect("changed", self, "_on_variable_changed")
	Global.editor_variables.erase(obj.property)
	Global.editor_variables[new_name] = obj.get_value()
	obj.connect("changed", self, "_on_variable_changed", [new_name])

func _on_Search_text_changed(new_text: String) -> void:
	for edit in variables_container.get_children():
		if edit is VariableEdit:
			if new_text.empty() or new_text in edit.property:
				edit.show()
			else:
				edit.hide()

func _on_variable_changed(new_value: String, property: String) -> void:
	var res := Global.eval_property(new_value)
	if res[0] == OK:
		Global.change_variant(property, res[1])

func _on_variable_remove(property: String) -> void:
	Global.editor_variables.erase(property)
