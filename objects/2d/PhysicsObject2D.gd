extends Area2D
class_name PhysicsObject2D

export var mass: float = 1.0
export var charge := 0.0 setget set_charge
export var velocity := Vector2.ZERO
export var no_gravitation: bool = false
export var no_coulomb: bool = false

func set_charge(v: float):
	charge = v
	if not is_inside_tree():
		yield(self, "ready")
	if is_zero_approx(charge):
		sprite.texture = preload("res://assets/textures/object.png")
	elif charge > 0.0:
		sprite.texture = preload("res://assets/textures/positive_object.png")
	elif charge < 0.0:
		sprite.texture = preload("res://assets/textures/nagetive_object.png")


onready var sprite = $Sprite
onready var shape: CollisionShape2D = $CollisionShape2D
onready var remote_transform: RemoteTransform2D = $RemoteTransform2D


var acceleration := Vector2.ZERO
var force := Vector2.ZERO

var fields: Array = []
var fields_refresh_counter: int = 0

var is_current := false setget set_current

func _ready() -> void:
	Global.connect("camera_detach", self, "_on_camera_detach")

func enforce(F: Vector2) -> void:
	force += F

func field_enforce() -> void:
	force = Vector2.ZERO
	fields_refresh_counter += 1
	if fields_refresh_counter >= max(1, int(Global.UpdateFrequency * Global.DecelerationRatio * 3)):
		fields.clear()
		fields_refresh_counter = 0
		for field in get_tree().get_nodes_in_group("fields"):
			if field.is_colliding(self):
				fields.push_back(field)
	for field in fields:
		if is_instance_valid(field):
			field.enforce(self)

func _physics_process(delta: float) -> void:
	for i in Global.UpdateFrequency:
		acceleration = force / mass
		velocity += acceleration * delta / Global.UpdateFrequency * Global.DecelerationRatio
		position += velocity * delta / Global.UpdateFrequency * Global.DecelerationRatio
		field_enforce()

func _on_MouseSensor_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed:
		self.is_current = not is_current

func set_current(v: bool):
	is_current = v
	if is_current:
		remote_transform.remote_path = Global.current_camera.get_path()
	else:
		remote_transform.remote_path = NodePath()

func _on_camera_detach():
	if is_current:
		self.is_current = false
