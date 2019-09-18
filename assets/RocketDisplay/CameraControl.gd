extends Spatial

export (float) var max_zoom_distance : float = 50.0
export (float) var min_zoom_distance : float = 2.5
export (float) var zoom_step_size : float = 0.5
export (float, 0, 500) var speed : float = 5
export (NodePath) var camera_path : NodePath

onready var camera : Node = get_node(camera_path)

const MOUSE_SENSITIVITY : float = 0.4
const MAX_UP_AIM_ANGLE : float = 55.0
const MAX_DOWN_AIM_ANGLE : float = 55.0

var current_zoom_distance : float = 20.0
var enabled : bool = false
var current_look_position : Vector3 = Vector3()
var target_rotation_degrees : Vector3 = Vector3()
var look_direction : Vector2 = Vector2()
var mouse_down : bool = false

func _physics_process(delta) -> void:
	if not enabled:
		return

	$CameraPosition.translation = $CameraPosition.translation.linear_interpolate(Vector3(0, 0, current_zoom_distance), delta * speed)
	rotation_degrees = rotation_degrees.linear_interpolate(target_rotation_degrees, delta * speed)

	if rotation_degrees.y < -180:
		look_direction.x += 360
		rotation_degrees.y = 180
		target_rotation_degrees.y += 360
	elif rotation_degrees.y > 180:
		look_direction.x -= 360
		rotation_degrees.y = -180
		target_rotation_degrees.y -= 360

func set_enabled(var _enabled) -> void:
	if _enabled:
		current_zoom_distance = $CameraPosition.translation.z
		look_direction.y = rotation_degrees.x
		look_direction.x = rotation_degrees.y
		target_rotation_degrees = Vector3(look_direction.y, look_direction.x, 0)

	enabled = _enabled

func _input(event) -> void:
	if not enabled:
		return
	if event.is_action("scroll_down"):
		increase_distance()
	if event.is_action("scroll_up"):
		decrease_distance()

	if Input.is_action_pressed("left_click"):
		mouse_down = true
	else:
		mouse_down = false

	if mouse_down and event is InputEventMouseMotion:
		look_direction.x -= event.relative.x * MOUSE_SENSITIVITY
		look_direction.y -= event.relative.y * MOUSE_SENSITIVITY

		if look_direction.y > MAX_UP_AIM_ANGLE:
			look_direction.y = MAX_UP_AIM_ANGLE
		elif look_direction.y < -MAX_DOWN_AIM_ANGLE:
			look_direction.y = -MAX_DOWN_AIM_ANGLE

		target_rotation_degrees = Vector3(look_direction.y, look_direction.x, 0)

func increase_distance() -> void:
	if not enabled:
		return
	if current_zoom_distance < max_zoom_distance:
		current_zoom_distance += zoom_step_size

func decrease_distance() -> void:
	if not enabled:
		return
	if current_zoom_distance > min_zoom_distance:
		current_zoom_distance -= zoom_step_size
