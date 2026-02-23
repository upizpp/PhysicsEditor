extends PanelContainer


onready var container: FoldableContainer = $ScrollContainer/FoldableContainer

func get_current() -> Dictionary:
	return container.object

func load_object(object: Dictionary) -> void:
	container.group_name = object.name
	container.unfold()
	clear()
	container.show()
	edit(object, container, object["__bind__"])

func clear() -> void:
	container.hide()
	for c in container.container.get_children():
		c.queue_free()

func edit(object: Dictionary, base: FoldableContainer, bind: Node2D) -> void:
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
			base.add(property).value = Global.to_editable(object[property])
