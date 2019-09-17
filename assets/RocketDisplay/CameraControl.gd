extends Spatial

export (float) var max_zoom_distance = 50.0
export (float) var min_zoom_distance = 2.5
export (float) var zoom_step_size = 0.5
export (float, 0, 500) var speed = 5
var current_zoom_distance = 20.0
var enabled = false
export (NodePath) var camera_path
onready var camera = get_node(camera_path)
var current_look_position = Vector3()
var target_rotation_degrees = Vector3()
var look_direction = Vector2()
var mouse_sensitivity = 0.4
var max_up_aim_angle = 55.0
var max_down_aim_angle = 55.0
var mouse_down = false

func _physics_process(delta):
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

func SetEnabled(var _enabled):
	if _enabled:
		current_zoom_distance = $CameraPosition.translation.z
		look_direction.y = rotation_degrees.x
		look_direction.x = rotation_degrees.y
		target_rotation_degrees = Vector3(look_direction.y, look_direction.x, 0)
	
	enabled = _enabled

func _input(event):
	if not enabled:
		return
	if event.is_action("scroll_down"):
		IncreaseDistance()
	if event.is_action("scroll_up"):
		DecreaseDistance()
	
	if Input.is_action_pressed("left_click"):
		mouse_down = true
	else:
		mouse_down = false
	
	if mouse_down and event is InputEventMouseMotion:
		look_direction.x -= event.relative.x * mouse_sensitivity
		look_direction.y -= event.relative.y * mouse_sensitivity
		
		if look_direction.y > max_up_aim_angle:
			look_direction.y = max_up_aim_angle
		elif look_direction.y < -max_down_aim_angle:
			look_direction.y = -max_down_aim_angle
		
		target_rotation_degrees = Vector3(look_direction.y, look_direction.x, 0)

func IncreaseDistance():
	if not enabled:
		return
	if current_zoom_distance < max_zoom_distance:
		current_zoom_distance += zoom_step_size

func DecreaseDistance():
	if not enabled:
		return
	if current_zoom_distance > min_zoom_distance:
		current_zoom_distance -= zoom_step_size
