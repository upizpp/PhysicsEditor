extends PanelContainer

signal select(index)
signal remove(index)

onready var item_list: ItemList = $VBoxContainer/ItemList
onready var name_edit: LineEdit = $VBoxContainer/HBoxContainer/VBoxContainer/Name
onready var type_button: OptionButton = $VBoxContainer/HBoxContainer/VBoxContainer/Type
onready var shape_button: OptionButton = $VBoxContainer/HBoxContainer/VBoxContainer/Shape

const Types = [
	"object",
	"magnetic",
	"electric",
	"baffle"
]
const Shapes = [
	"matrix",
	"circle"
]

func load_scene(scene: Array) -> void:
	var counter := 1
	var index := 0
	for object in scene:
		if not object.has("name"):
			object["name"] = "Object%d" % counter
			counter += 1
		item_list.add_item(object["name"])
		item_list.set_item_metadata(index, object)
		index += 1

func clear() -> void:
	item_list.clear()
	name_edit.clear()

func add() -> void:
	if name_edit.text.empty():
		return
	var obj := {
		"name": name_edit.text,
		"type": Types[type_button.selected],
		"properties": {}
	}
	if obj.type != "object":
		obj["shape"] = Shapes[shape_button.selected]
	item_list.add_item(obj.name)
	Global.editor_scene.append(obj)
	Global.editor.scene_preview.create_object(obj)
	
	item_list.set_item_metadata(item_list.get_item_count() - 1, obj)
	name_edit.text = ""

func select(index: int) -> void:
	item_list.select(index)
	_on_ItemList_item_selected(index)

func rename(index: int, new_name: String) -> void:
	item_list.set_item_text(index, new_name)

func get_data(index: int) -> Dictionary:
	return item_list.get_item_metadata(index)

func _on_Add_text_entered(new_text: String) -> void:
	add()

func _on_ItemList_item_rmb_selected(index: int, at_position: Vector2) -> void:
	emit_signal("remove", index)
	item_list.remove_item(index)
	Global.editor_scene.remove(index)

func _on_ItemList_item_selected(index: int) -> void:
	emit_signal("select", index)
