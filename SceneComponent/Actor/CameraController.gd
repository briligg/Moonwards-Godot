# Inspired by Guillaume Roy's script
# https://github.com/TheFamousRat/GodotUtility/blob/master/3d/3D%20Cameras/3rdPersonCamera.gd
extends AComponent
class_name CameraController

export(float) var dist: float = .5
export(float) var max_pitch: float = 55
var mouse_sensitivity: float = 0.1

var yaw: float = 0.0
var pitch: float = 0.0

onready var camera: Camera = $Camera
onready var pivot: Spatial = $Pivot

func _init().("CameraController"):
	pass
	
func _ready():
	yaw = 0.0
	pitch = 0.0
	_set_cam_pos()
	camera.add_exception(entity)

func _input(event):
	if event is InputEventMouseMotion:
		var mouse_vec : Vector2 = event.get_relative()
		
		yaw = fmod(yaw - mouse_vec.x * mouse_sensitivity, 360.0)
		pitch = max(min(pitch - mouse_vec.y * mouse_sensitivity , max_pitch), -max_pitch)
		
		var _new_rot = Vector3(deg2rad(pitch), deg2rad(yaw), 0.0)
		camera.set_rotation(_new_rot)
		
		_set_cam_pos()

func _set_cam_pos() -> void:
	# Ray normal from the exact center of the viewport
	var r = camera.project_ray_normal(get_viewport().get_visible_rect().size * 0.5)
	# Set cam position
	camera.set_translation(pivot.transform.origin - dist * r)
