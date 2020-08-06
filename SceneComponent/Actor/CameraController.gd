# Inspired by Guillaume Roy's script
# https://github.com/TheFamousRat/GodotUtility/blob/master/3d/3D%20Cameras/3rdPersonCamera.gd
extends AComponent
class_name CameraController

onready var camera: Camera = $Camera
onready var pivot: Spatial = $Pivot

export(float) var dist: float = .5
export(float) var max_pitch: float = 55
export(float) var cull_col_distance: float = 0.1
onready var excluded_cull_bodies = [entity]

var mouse_sensitivity: float = 0.1
var yaw: float = 0.0
var pitch: float = 0.0

func _init().("Camera", true):
	pass
	
func _ready() -> void:
	yaw = 0.0
	pitch = 0.0
	_update_cam_pos()
	camera.set_as_toplevel(true)

func _process(_delta: float) -> void:
	var _new_rot = Vector3(deg2rad(pitch), deg2rad(yaw), 0.0)
	camera.set_rotation(_new_rot)
	_update_cam_pos()
	var t = camera.global_transform.origin
	entity.look_dir.y = entity.global_transform.origin.y
	entity.look_dir.x = t.x
	entity.look_dir.z = t.z

func _input(event):
	if event is InputEventMouseMotion:
		var mouse_vec : Vector2 = event.get_relative()
		yaw = fmod(yaw - mouse_vec.x * mouse_sensitivity, 360.0)
		pitch = max(min(pitch - mouse_vec.y * mouse_sensitivity , max_pitch), -max_pitch)

func _update_cam_pos() -> void:
	var new_cam_pos = global_transform.origin - _get_cam_normal() * dist
	# Check if the new pos is behind collidable objects
	var ray = get_world().direct_space_state.intersect_ray(pivot.global_transform.origin, new_cam_pos, excluded_cull_bodies)
	if not ray.empty():
		new_cam_pos = ray["position"]
		
	camera.global_transform.origin = new_cam_pos
	pass

# Ray normal from the exact center of the viewport
func _get_cam_normal() -> Vector3:
	return camera.project_ray_normal(get_viewport().get_visible_rect().size * 0.5)
	
func disable():
	.disable()

func enable():
	if Network.network_instance.peer_id == entity.owner_peer_id:
		camera.set_current(true)
	.enable()
