extends Node


signal camera_detach


const WindowSize = Vector2(1280, 640)


# 1gs = 1s * DecelerationRatio (game seconds)
var UpdateFrequency := 10
var DecelerationRatio := 0.2

var current_camera: Camera2D

var editor_scene := []
var editor_variables := {}
var editor_variables_parsed := {}

var editor: Editor

var target_file: String

func _ready() -> void:
	var args := OS.get_cmdline_args()
	if not args.empty() and args[0].ends_with("json"):
		target_file = args[0]
		get_tree().change_scene("res://objects/2d/editor/ScenePlayer.tscn")

func load_file(path: String) -> String:
	target_file = path
	var data = SceneReader.read(path)
	if not data[0].empty():
		return data[0]
	editor_scene = data[1]
	editor_variables = data[2]
	editor_variables_parsed = SceneReader.parse_variables(editor_variables.duplicate(false))
	
	if editor_variables_parsed.has("UpdateFrequency"):
		UpdateFrequency = editor_variables_parsed["UpdateFrequency"]
	elif editor_variables_parsed.has("UF"):
		UpdateFrequency = editor_variables_parsed["UF"]
	if editor_variables_parsed.has("DecelerationRatio"):
		DecelerationRatio = editor_variables_parsed["DecelerationRatio"]
	elif editor_variables_parsed.has("DR"):
		DecelerationRatio = editor_variables_parsed["DR"]
	
	return ""

func save_file(path: String) -> void:
	if path.empty():
		printerr("未打开文件，保存失败。")
		return
	var file = File.new()
	file.open(path, File.WRITE)
	file.store_string(SceneReader.var2json({
		"variables": editor_variables.duplicate(true),
		"scene": editor_scene.duplicate(true)
	}))
	file.close()

func eval_property(pattern: String) -> Array:
	var expr := Expression.new()
	var err := expr.parse(pattern, editor_variables_parsed.keys())
	if err != OK:
		return [err, null]
	return [OK, expr.execute(editor_variables_parsed.values(), null, false)]

func change_variant(property: String, value) -> void:
	editor_variables[property] = value
	var arr := eval_property(value)
	if arr[0] == OK:
		editor_variables_parsed[property] = arr[1]
	if value is int or value is float:
		if property == "UpdateFrequency" or property == "UF":
			UpdateFrequency = value
		elif property == "DecelerationRatio" or property == "DR":
			DecelerationRatio = value

func to_editable(value) -> String:
	if value is String:
		return value
	else:
		return var2str(value)

func quit() -> void:
	if not target_file.empty():
		save_file(target_file)
	get_tree().quit()

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_QUIT_REQUEST or what == NOTIFICATION_WM_GO_BACK_REQUEST:
		quit()
