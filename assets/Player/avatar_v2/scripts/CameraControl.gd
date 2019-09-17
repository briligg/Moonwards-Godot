extends Spatial
var id = "CameraControl"

export (NodePath) var kinematic_body_path
export (NodePath) var kinematic_body_camera
export (float, 0, 500) var speed = 5
onready var kinematic_body = get_node(kinematic_body_path)
onready var pivot = $Pivot
onready var camera_target = $Pivot/CameraTarget
onready var look_target = $Pivot/LookTarget
onready var camera = get_node(kinematic_body_camera)
var current_look_position = Vector3()
export (bool) var enabled = false
export (float) var max_zoom_distance = 1.0
export (float) var min_zoom_distance = 0.15
export (float) var zoom_step_size = 0.05
var excluded_bodies = []

func _ready():
	if camera == null:
		enabled = false
		printd("camera not defined, disabled")
	else:
		var camera_far = 50000
		printd("camera found, enabled, set far %s" % camera_far)
		camera.far = camera_far
		camera.global_transform.origin = camera_target.global_transform.origin
		current_look_position = look_target.global_transform.origin
		camera.look_at(current_look_position, Vector3(0,1,0))
		excluded_bodies.append(kinematic_body)

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
	
	camera.global_transform.origin = camera.global_transform.origin.linear_interpolate(target_position, delta * speed)
	
	var new_look_position = look_target.global_transform.origin
	current_look_position = current_look_position.linear_interpolate(new_look_position, delta * speed)
	camera.look_at(current_look_position, Vector3(0,1,0))

func Rotate(var direction):
	pivot.rotation_degrees = Vector3(direction.y, direction.x, 0)

func DrawLine(var from, var to):
	var im = $Lines
	im.clear()
	im.begin(Mesh.PRIMITIVE_LINE_STRIP, null)
	var origin = im.global_transform.origin
	
	im.add_vertex(from - origin)
	im.add_vertex(to - origin)
	
	im.end()

func printd(s):
	logg.print_filtered_message(id, s)
