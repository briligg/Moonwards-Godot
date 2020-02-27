extends Spatial
#var id = "CameraControl"

export (NodePath) var kinematic_body_path
export (NodePath) var kinematic_body_camera
export (float, 0, 500) var speed = 5
onready var kinematic_body = get_node(kinematic_body_path)
onready var pivot = $Pivot
onready var camera_target = $Pivot/CameraTarget
onready var look_target = $Pivot/LookTarget
onready var raycast = $RayCast
onready var camera = get_node(kinematic_body_camera)
var current_look_position = Vector3()
export (bool) var enabled = false
export (float) var default_zoom_distance = 0.25
export (float) var max_zoom_distance = 1.0
export (float) var min_zoom_distance = 0.15
export (float) var zoom_step_size = 0.05
var look_direction = Vector2()
var mouse_sensitivity = 0.10
var max_up_aim_angle = 55.0
var max_down_aim_angle = 55.0

func _ready():
	var camera_far = 50000
	camera.far = camera_far
	camera.global_transform.origin = camera_target.global_transform.origin
	current_look_position = look_target.global_transform.origin
	camera.look_at(current_look_position, Vector3(0,1,0))
	raycast.add_exception(kinematic_body)
	camera_target.translation.z = default_zoom_distance
	set_camera_control(enabled)

func _input(event):
	if (event is InputEventMouseMotion):
		look_direction.x -= event.relative.x * mouse_sensitivity
		look_direction.y -= event.relative.y * mouse_sensitivity
		
		if look_direction.x > 360:
			look_direction.x = 0
		elif look_direction.x < 0:
			look_direction.x = 360
		if look_direction.y > max_up_aim_angle:
			look_direction.y = max_up_aim_angle
		elif look_direction.y < -max_down_aim_angle:
			look_direction.y = -max_down_aim_angle
		
		_rotate_camera(look_direction)
	
	if event.is_action("zoom_in") and not Input.is_action_pressed("move_run"):
		_decrease_distance()

	if event.is_action("zoom_out") and not Input.is_action_pressed("move_run"):
		_increase_distance()

func set_camera_control(var _enabled):
	enabled = _enabled
	if enabled:
		set_process_input(true)
		set_physics_process(true)
		camera.current = true
	else:
		set_process_input(false)
		set_physics_process(false)
		camera.current = false

func _increase_distance():
	if not enabled:
		return
	if camera_target.translation.z < max_zoom_distance:
		camera_target.translation.z += zoom_step_size

func _decrease_distance():
	if not enabled:
		return
	if camera_target.translation.z > min_zoom_distance:
		camera_target.translation.z -= zoom_step_size

func _physics_process(delta):
	var from = pivot.global_transform.origin
	var to = camera_target.global_transform.origin
	var local_to = camera_target.translation
	
	raycast.cast_to = raycast.to_local(to)
	
	var target_position = to
	if raycast.is_colliding():
		if raycast.get_collider().is_in_group("no_camera_collide"):
			raycast.add_exception(raycast.get_collider())
			return
		var raycast_offset = raycast.get_collision_point().distance_to(from)
		if local_to.z > raycast_offset:
			target_position = pivot.to_global(Vector3(0, 0, max(0.05, raycast_offset - 0.15)))
	
	camera.global_transform.origin = camera.global_transform.origin.linear_interpolate(target_position, delta * speed)
	
	var new_look_position = look_target.global_transform.origin
	current_look_position = current_look_position.linear_interpolate(new_look_position, delta * speed)
	camera.look_at(current_look_position, Vector3(0,1,0))

func _rotate_camera(var direction):
	pivot.rotation_degrees = Vector3(direction.y, direction.x, 0)

