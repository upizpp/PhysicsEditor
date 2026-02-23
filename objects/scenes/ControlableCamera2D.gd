extends Camera2D
class_name ControlableCamera2D

const ZoomDelta = 0.02

export var up_action := "ui_up"
export var down_action := "ui_down"
export var left_action := "ui_left"
export var right_action := "ui_right"
export var rotate_left_action := "rotate_left"
export var rotate_right_action := "rotate_right"
export var zoom_up_action := "zoom_up"
export var zoom_down_action := "zoom_down"
export var speed := 500.0

func _ready() -> void:
	rotating = true
	make_current()
	Global.current_camera = self

func _process(delta: float) -> void:
	var input := Input.get_vector(
		left_action, right_action,
		up_action, down_action
	)
	if input != Vector2.ZERO:
		Global.emit_signal("camera_detach")
	position += input * speed * delta
	if Input.is_action_pressed(rotate_left_action):
		rotation_degrees += 2
	if Input.is_action_pressed(rotate_right_action):
		rotation_degrees -= 2
	if Input.is_action_pressed(zoom_up_action):
		zoom += Vector2(ZoomDelta, ZoomDelta)
	if Input.is_action_pressed(zoom_down_action):
		zoom -= Vector2(ZoomDelta, ZoomDelta)
