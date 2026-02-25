extends Node2D

signal move(position)
signal resize(scale)
signal clicked

const Width = 8

export var size := Vector2(128, 128) setget _set_size
export var scaleable: bool = true setget set_scaleable
export var lock_y := 0.0

var bind: Dictionary

func _set_size(v: Vector2) -> void:
	size = v
	if not is_zero_approx(lock_y):
		size.y = lock_y
	update()
	if not is_inside_tree():
		yield(self, "ready")
	up_control.rect_size = Vector2(size.x, Width)
	up_control.rect_position = Vector2(0.0, -(size.y + Width) / 2.0) - up_control.rect_size * 0.5
	down_control.rect_size = Vector2(size.x, Width)
	down_control.rect_position = Vector2(0.0, (size.y + Width) / 2.0) - down_control.rect_size * 0.5
	left_control.rect_size = Vector2(Width, size.y)
	left_control.rect_position = Vector2(-(size.x + Width) / 2.0, 0.0) - left_control.rect_size * 0.5
	right_control.rect_size = Vector2(Width, size.y)
	right_control.rect_position = Vector2((size.x + Width) / 2.0, 0.0) - right_control.rect_size * 0.5
	center_control.rect_size.x = size.x * 0.5 if size.x < 50 else (size.x - 50)
	center_control.rect_size.y = size.y * 0.5 if size.y < 50 else (size.y - 50)
	center_control.rect_position = -center_control.rect_size * 0.5

func set_scaleable(v: bool) -> void:
	scaleable = v
	if not is_inside_tree():
		yield(self, "ready")
	if scaleable:
		up_control.mouse_default_cursor_shape = Control.CURSOR_VSIZE
		down_control.mouse_default_cursor_shape = Control.CURSOR_VSIZE
		left_control.mouse_default_cursor_shape = Control.CURSOR_HSIZE
		right_control.mouse_default_cursor_shape = Control.CURSOR_HSIZE
	else:
		up_control.mouse_default_cursor_shape = Control.CURSOR_ARROW
		down_control.mouse_default_cursor_shape = Control.CURSOR_ARROW
		left_control.mouse_default_cursor_shape = Control.CURSOR_ARROW
		right_control.mouse_default_cursor_shape = Control.CURSOR_ARROW
	emit_resize()

onready var up_control: Control = $UpControl
onready var down_control: Control = $DownControl
onready var left_control: Control = $LeftControl
onready var right_control: Control = $RightControl
onready var center_control: Control = $CenterControl

func _ready() -> void:
	self.size = size

func _draw() -> void:
	draw_rect(Rect2(-size * 0.5, size), Color.snow, true)
	draw_rect(Rect2(-size * 0.5, size), Color.black, false, 1.5, true)
#	var c := Color.deepskyblue
#	c.a = 0.5
#	draw_rect(up_control.get_rect(), c)
#	draw_rect(down_control.get_rect(), c)
#	draw_rect(left_control.get_rect(), c)
#	draw_rect(right_control.get_rect(), c)
#	draw_rect(center_control.get_rect(), c)

enum {
	UP,
	DOWN,
	LEFT,
	RIGHT,
	MOVE
}

var dragging := false
var which_area := 0
var source := Vector2.ZERO
var initial_size := Vector2.ZERO
var initial_position := Vector2.ZERO

func emit_resize() -> void:
	if bind:
		bind["properties"]["size"] = size
	emit_signal("resize", size)

func emit_move() -> void:
	if bind:
		bind["properties"]["position"] = position
	emit_signal("move", position)

func _input(event: InputEvent) -> void:
	if dragging and event is InputEventMouseButton and not event.pressed and event.button_index == BUTTON_LEFT:
		dragging = false
	var s := size
	var p := position
	if dragging and event is InputEventMouseMotion:
		match which_area:
			UP:
				if not is_zero_approx(lock_y):
					return
				if not scaleable:
					return
				var delta: float = (source - event.global_position).rotated(-rotation).y / get_global_transform().get_scale().y
				self.size.y = initial_size.y + delta
				position = initial_position + Vector2.UP.rotated(rotation) * delta / 2.0
				emit_move()
				emit_resize()
			DOWN:
				if not is_zero_approx(lock_y):
					return
				if not scaleable:
					return
				var delta: float = (source - event.global_position).rotated(-rotation).y / get_global_transform().get_scale().y
				self.size.y = initial_size.y - delta
				position = initial_position + Vector2.UP.rotated(rotation) * delta / 2.0
				emit_move()
				emit_resize()
			LEFT:
				if not scaleable:
					return
				var delta: float = (source - event.global_position).rotated(-rotation).x / get_global_transform().get_scale().x
				self.size.x = initial_size.x + delta
				position = initial_position + Vector2.LEFT.rotated(rotation) * delta / 2.0
				emit_move()
				emit_resize()
			RIGHT:
				if not scaleable:
					return
				var delta: float = (source - event.global_position).rotated(-rotation).x / get_global_transform().get_scale().x
				self.size.x = initial_size.x - delta
				position = initial_position + Vector2.LEFT.rotated(rotation) * delta / 2.0
				emit_move()
				emit_resize()
			MOVE:
				var delta: Vector2 = (source - event.global_position) / get_global_transform().get_scale()
				position = initial_position - delta
				emit_move()
	if size.x <= 0 or size.y <= 0:
		self.size = s
		position = p


func _on_gui_input(event: InputEvent, which: int) -> void:
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed:
		dragging = event.pressed
		source = event.global_position
		initial_size = size
		initial_position = position
		which_area = which
		emit_signal("clicked")
