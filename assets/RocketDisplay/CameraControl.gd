extends Spatial

export (float) var max_zoom_distance : float = 50.0
export (float) var min_zoom_distance : float = 2.5
export (float) var zoom_step_size : float = 0.5
export (float, 0, 500) var speed : float = 5

const MOUSE_SENSITIVITY : float = 0.4
const MAX_UP_AIM_ANGLE : float = 55.0
const MAX_DOWN_AIM_ANGLE : float = 55.0

onready var _camera_position : Node = $CameraPosition

var _current_zoom_distance : float = 20.0
var _target_rotation_degrees : Vector3 = Vector3()
var _look_direction : Vector2 = Vector2()
var _mouse_down : bool = false

func _ready():
	set_physics_process(false)
	set_process_input(false)

func _physics_process(delta : float) -> void:
	_camera_position.translation = _camera_position.translation.linear_interpolate(Vector3(0, 0, _current_zoom_distance), delta * speed)
	rotation_degrees = rotation_degrees.linear_interpolate(_target_rotation_degrees, delta * speed)

	if rotation_degrees.y < -180:
		_look_direction.x += 360
		rotation_degrees.y = 180
		_target_rotation_degrees.y += 360
	elif rotation_degrees.y > 180:
		_look_direction.x -= 360
		rotation_degrees.y = -180
		_target_rotation_degrees.y -= 360

func set_enabled(enabled : bool) -> void:
	if enabled:
		_current_zoom_distance = _camera_position.translation.z
		_look_direction.y = rotation_degrees.x
		_look_direction.x = rotation_degrees.y
		_target_rotation_degrees = Vector3(_look_direction.y, _look_direction.x, 0)
	
	set_physics_process(enabled)
	set_process_input(enabled)

func _input(event : InputEvent) -> void:
	if event.is_action("zoom_out"):
		increase_distance()
	if event.is_action("zoom_in"):
		decrease_distance()

	if Input.is_action_pressed("left_click"):
		_mouse_down = true
	else:
		_mouse_down = false

	if _mouse_down and event is InputEventMouseMotion:
		_look_direction.x -= event.relative.x * MOUSE_SENSITIVITY
		_look_direction.y -= event.relative.y * MOUSE_SENSITIVITY

		if _look_direction.y > MAX_UP_AIM_ANGLE:
			_look_direction.y = MAX_UP_AIM_ANGLE
		elif _look_direction.y < -MAX_DOWN_AIM_ANGLE:
			_look_direction.y = -MAX_DOWN_AIM_ANGLE

		_target_rotation_degrees = Vector3(_look_direction.y, _look_direction.x, 0)

func increase_distance() -> void:
	if _current_zoom_distance < max_zoom_distance:
		_current_zoom_distance += zoom_step_size

func decrease_distance() -> void:
	if _current_zoom_distance > min_zoom_distance:
		_current_zoom_distance -= zoom_step_size
