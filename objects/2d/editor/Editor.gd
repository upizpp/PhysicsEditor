extends Control
class_name Editor

onready var scene_preview: ColorRect = $"%ScenePreview"
onready var property_editor: PanelContainer = $"%PropertyEditor"
onready var variables_editor: PanelContainer = $"%VariablesEditor"
onready var scene_editor: PanelContainer = $"%SceneEditor"
onready var file_dialog: FileDialog = $FileDialog
onready var warning_dialog: AcceptDialog = $WarningDialog

func _ready() -> void:
	get_tree().set_screen_stretch(SceneTree.STRETCH_MODE_DISABLED, SceneTree.STRETCH_ASPECT_IGNORE, Vector2(640, 320))
	
	$Body/HSplitContainer/HSplitContainer/TabContainer1.set_tab_title(0, "属性编辑器")
	$Body/HSplitContainer/HSplitContainer/TabContainer1.set_tab_title(1, "变量编辑器")
	$Body/HSplitContainer/HSplitContainer/TabContainer2.set_tab_title(0, "场景编辑器")
	
	Global.editor = self
	if not Global.target_file.empty():
		load_file(Global.target_file)

func clear() -> void:
	Global.editor_scene.clear()
	Global.editor_variables.clear()
	property_editor.clear()
	variables_editor.clear()
	scene_editor.clear()
	scene_preview.clear()

func load_file(path: String) -> String:
	clear()
	
	var msg: String = Global.load_file(path)
	if not msg.empty():
		return msg
	
	scene_editor.load_scene(Global.editor_scene)
	scene_preview.load_scene(Global.editor_scene)
	variables_editor.load_variables(Global.editor_variables)
	
	return ""

func save_file(path: String) -> void:
	if path.empty():
		printerr("未打开文件，保存失败。")
		return
	var file = File.new()
	file.open(path, File.WRITE)
	file.store_string(SceneReader.var2json({
		"variables": Global.editor_variables.duplicate(true),
		"scene": Global.editor_scene.duplicate(true)
	}))
	file.close()

func run() -> void:
	save_file(Global.target_file)
	get_tree().change_scene("res://objects/2d/editor/ScenePlayer.tscn")


func _on_SceneEditor_select(index: int) -> void:
	property_editor.load_object(scene_editor.get_data(index))

func _on_SceneEditor_remove(index: int) -> void:
	scene_editor.get_data(index)["__bind__"].queue_free()
	property_editor.clear()

func _on_Run_pressed() -> void:
	run()

func _on_Save_pressed() -> void:
	save_file(Global.target_file)

enum {
	NEW,
	OPEN,
	SAVE_TO
}
var mode := 0
func _on_Open_pressed() -> void:
	file_dialog.popup_centered_ratio()
	file_dialog.mode = FileDialog.MODE_OPEN_FILE
	mode = OPEN

func _on_New_pressed() -> void:
	file_dialog.popup_centered_ratio()
	file_dialog.mode = FileDialog.MODE_SAVE_FILE
	mode = NEW

func _on_SaveTo_pressed() -> void:
	file_dialog.popup_centered_ratio()
	file_dialog.mode = FileDialog.MODE_SAVE_FILE
	mode = SAVE_TO

func _on_FileDialog_file_selected(path: String) -> void:
	match mode:
		NEW:
			var file := File.new()
			file.open(path, File.WRITE)
			file.store_string('{"variables":{},"scene":[]}')
			file.close()
			var msg := load_file(path)
			if not msg.empty():
				warning_dialog.dialog_text = msg
				warning_dialog.popup_centered_ratio(0.25)
		OPEN:
			var msg := load_file(path)
			if not msg.empty():
				warning_dialog.dialog_text = msg
				warning_dialog.popup_centered_ratio(0.25)
		SAVE_TO:
			save_file(path)
			Global.target_file = path
