tool	
extends EditorScript


func _run() -> void:
	save_icon("ResourcePreloader")

func save_icon(what: String) -> void:
	var theme := get_editor_interface().get_base_control().theme
	var img := theme.get_icon(what, "EditorIcons").get_data()
	what = what.to_lower()
	img.save_png("res://assets/textures/%s.png" % what)
	img.lock()
	for x in img.get_width():
		for y in img.get_height():
			var a := img.get_pixel(x, y).a
			if a != 0:
				var col := Color("699CE8")
				col.a = a
				img.set_pixel(x, y, col)
	img.unlock()
	img.save_png("res://assets/textures/%s_pressed.png" % what)
	img.lock()
	for x in img.get_width():
		for y in img.get_height():
			var a := img.get_pixel(x, y).a
			if a != 0:
				var col := Color("FFFFFF")
				col.a = a
				img.set_pixel(x, y, col)
	img.unlock()
	img.save_png("res://assets/textures/%s_hover.png" % what)
