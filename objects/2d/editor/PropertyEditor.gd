extends PanelContainer

signal object_renamed(new_name, object)

onready var container: FoldableContainer = $ScrollContainer/FoldableContainer

func get_current() -> Dictionary:
	return container.object

func load_object(object: Dictionary) -> void:
	container.group_name = object.name
	container.unfold()
	clear()
	container.show()
	edit(object, container, object["__bind__"], true)

func clear() -> void:
	container.hide()
	for c in container.container.get_children():
		c.queue_free()

func edit(object: Dictionary, base: FoldableContainer, bind: Node2D, first: bool = false) -> void:
	base.object = object
	base.bind = bind
	for property in object:
		if property.begins_with("__") and property.ends_with("__"):
			continue
		if object[property] is Dictionary:
			var container := preload("res://objects/2d/editor/FoldableContainer.tscn").instance()
			container.group_name = property
			container.connect("remove", base, "_on_property_removed")
			base.container.add_child(container)
			edit(object[property], container, bind)
		else:
			var obj := base.add(property)
			obj.value = Global.to_editable(object[property])
			if first and property == "name":
				obj.connect("changed", self, "_on_name_changed", [object])

func _on_name_changed(new_name: String, obj: Dictionary) -> void:
	emit_signal("object_renamed", new_name, obj)
