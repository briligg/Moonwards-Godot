extends AComponent
class_name CameraController

export (float, 0, 500) var pos_speed = 15
export (float, 0, 500) var look_speed = 15
onready var pivot = $Pivot
onready var camera_target = $Pivot/CameraTarget
onready var look_target = $Pivot/LookTarget
onready var camera = $Camera

var current_look_position = Vector3()
export (float) var max_zoom_distance = 1.0
export (float) var min_zoom_distance = 0.15
export (float) var zoom_step_size = 0.05
var excluded_bodies = []
#### Move this to settings later when its re-implemented
var mouse_sensitivity: float = 0.10
var max_up_aim_angle = 55.0
var max_down_aim_angle = 55.0

func _init().("CameraController"):
	pass

func _ready():
	assert(camera != null)
	if camera == null:
		enabled = false
		#printd("camera not defined, disabled")
	else:
		var camera_far = 50000
		#printd("camera found, enabled, set far %s" % camera_far)
		camera.far = camera_far
		camera.global_transform.origin = camera_target.global_transform.origin
		current_look_position = look_target.global_transform.origin
		camera.look_at(current_look_position, Vector3(0,1,0))
		camera.current = true
		excluded_bodies.append(entity)

func IncreaseDistance():
	if not enabled:
		return
	if camera_target.translation.z < max_zoom_distance:
		camera_target.translation.z += zoom_step_size

func DecreaseDistance():
	if not enabled:
		return
	if camera_target.translation.z > min_zoom_distance:
		camera_target.translation.z -= zoom_step_size

func _physics_process(delta):
	if not enabled:
		return
	var from = pivot.global_transform.origin
	var to = camera_target.global_transform.origin
	var local_to = camera_target.translation
	
	var col = get_world().direct_space_state.intersect_ray(from, to, excluded_bodies)
	
	var target_position = to
	if not col.empty():
		if col.collider.is_in_group("no_camera_collide"):
			excluded_bodies.append(col.collider)
			return
		var raycast_offset = col.position.distance_to(from)
		if local_to.z > raycast_offset:
			target_position = pivot.to_global(Vector3(0, 0, max(0.05, raycast_offset - 0.15)))
	
	camera.global_transform.origin = target_position #camera.global_transform.origin.linear_interpolate(target_position, delta * pos_speed)
	
	var new_look_position = look_target.global_transform.origin
	current_look_position = new_look_position #current_look_position.linear_interpolate(new_look_position, delta * look_speed)
	camera.look_at(current_look_position, Vector3(0,1,0))

func _unhandled_input(event):
	if (event is InputEventMouseMotion):
		entity.look_dir.x -= event.relative.x * mouse_sensitivity
		entity.look_dir.y -= event.relative.y * mouse_sensitivity
		if entity.look_dir.x > 360:
			entity.look_dir.x = 0
		elif entity.look_dir.x < 0:
			entity.look_dir.x = 360
		if entity.look_dir.y > max_up_aim_angle:
			entity.look_dir.y = max_up_aim_angle
		elif entity.look_dir.y < -max_down_aim_angle:
			entity.look_dir.y = -max_down_aim_angle

		Rotate(entity.look_dir)

func Rotate(var direction):
	pivot.rotation_degrees = Vector3(direction.y, direction.x, 0)
