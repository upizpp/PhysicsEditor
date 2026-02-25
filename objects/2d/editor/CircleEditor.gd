extends Node2D

signal move(position)
signal resize(radius)
signal clicked

export var radius: float = 64.0 setget set_radius
export var scaleable: bool = true setget set_scaleable

func set_scaleable(v: bool) -> void:
	scaleable = v
	if not is_inside_tree():
		yield(self, "ready")
	if scaleable:
		scale_control.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	else:
		scale_control.mouse_default_cursor_shape = Control.CURSOR_ARROW

func set_radius(v: float) -> void:
	radius = abs(v)
	update()
	if not is_inside_tree():
		yield(self, "ready")
	move_control.rect_size = Vector2.ONE * radius / sqrt(2) * 2.0
	move_control.rect_position = -move_control.rect_size * 0.5
	scale_control.rect_size = Vector2.ONE * radius * 2.0 + Vector2(10, 10)
	scale_control.rect_position = -scale_control.rect_size * 0.5
	emit_resize()

onready var move_control: Control = $MoveControl
onready var scale_control: Control = $ScaleControl

var bind: Dictionary

func _ready() -> void:
	self.radius = radius

func _draw() -> void:
	draw_circle(Vector2.ZERO, radius, Color.snow)
	draw_arc(Vector2.ZERO, radius, 0.0, 2 * PI, int(radius / 2) + 32, Color.black, 1.5, true)
#	var c := Color.deepskyblue
#	c.a = 0.5
#	draw_rect(scale_control.get_rect(), c)
#	c = Color.dodgerblue
#	c.a = 0.5
#	draw_rect(move_control.get_rect(), c)

enum {
	SCALE,
	MOVE
}

func emit_resize() -> void:
	if not bind.empty():
		bind["properties"]["radius"] = radius
	emit_signal("resize", radius)

func emit_move() -> void:
	if not bind.empty():
		bind["properties"]["position"] = position
	emit_signal("move", position)

var dragging := false
var which_area := 0
var source := Vector2.ZERO
var initial_radius := 0.0
var initial_position := Vector2.ZERO

func _input(event: InputEvent) -> void:
	if dragging and event is InputEventMouseButton and not event.pressed and event.button_index == BUTTON_LEFT:
		dragging = false
	if dragging and event is InputEventMouseMotion:
		match which_area:
			MOVE:
				var delta: Vector2 = (source - event.global_position) / get_global_transform().get_scale()
				position = initial_position - delta
				emit_move()
			SCALE:
				if scaleable:
					self.radius = (global_position - event.global_position).length() / get_global_transform().get_scale().x
					emit_resize()


func _on_gui_input(event: InputEvent, which: int) -> void:
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed:
		dragging = event.pressed
		source = event.global_position
		initial_radius = radius
		initial_position = position
		which_area = which
		emit_signal("clicked")
