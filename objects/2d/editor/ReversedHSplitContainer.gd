extends HSplitContainer
class_name ReversedHSplitContainer

var initial_size_x := 952.0

func _ready():
	initial_size_x = rect_size.x
	connect("resized", self, "_on_resized")

func _on_resized() -> void:
	split_offset = int(rect_size.x - (initial_size_x - split_offset))
	initial_size_x = rect_size.x
