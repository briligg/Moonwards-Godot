# Inspired by Guillaume Roy's script
# https://github.com/TheFamousRat/GodotUtility/blob/master/3d/3D%20Cameras/3rdPersonCamera.gd
extends AComponent
class_name CameraController

onready var camera: Camera = $Camera
onready var pivot: Spatial = $Pivot

export(bool) var overriden = false #Use for bots only
export(bool) var allow_first_person = false
export(float) var dist: float = .5
export(float) var max_pitch: float = 55
export(float) var cull_col_distance: float = 0.1
onready var excluded_cull_bodies = [entity]

var mouse_sensitivity: float = 0.1
var yaw: float = 0.0
var pitch: float = 0.0

#This determines if I am in fps mode.
var is_first_person : bool = false
const HEAD_HEIGHT : float = 0.8

#Determines if I should freely fly or not.
var is_flying : bool = false
#How fast the player is flying.
var fly_speed : float = 40

const CHANGE_FLY_SPEED_BY : float = 2.0
const SLOWEST_POSSIBLE_FLIGHT_SPEED : float = 0.05


func _init().("Camera", true):
	pass
	
func _ready() -> void:
	yaw = 0.0
	pitch = 0.0
	_update_cam_pos()
	camera.set_as_toplevel(true)

func _process(_delta: float) -> void:
	#Set the camera back to regular mode if it is not the current camera.
	if not camera.is_current() :
		is_flying = false
		
		#Turn on the model if we were first person.
		if allow_first_person :
			entity.get_node("Model").visible = true
		return
	
	#Turn off the model if we are in first person mode.
	if is_first_person :
		entity.get_node("Model").visible = false
	
	var _new_rot = Vector3(deg2rad(pitch), deg2rad(yaw), 0.0)
	if not overriden:
		camera.set_rotation(_new_rot)
	_update_cam_pos()
	
	if not is_flying:
		entity.look_dir = global_transform.origin - _get_cam_normal() * dist
		#Below was code that did not seem to have a reason for being here.
		#Leave it here until we figure out if it should be here.
#		var t = camera.global_transform.origin
#		entity.look_dir.y = entity.global_transform.origin.y
#		entity.look_dir.x = t.x
#		entity.look_dir.z = t.z

func _input(event):
	if event is InputEventMouseMotion:
		var mouse_vec : Vector2 = event.get_relative()
		yaw = fmod(yaw - mouse_vec.x * mouse_sensitivity, 360.0)
		pitch = max(min(pitch - mouse_vec.y * mouse_sensitivity , max_pitch), -max_pitch)
	
	#Check to see if the player has started camera free fly.
	elif event.is_action_pressed("toggle_camera_fly") :
		is_flying = !is_flying
		Signals.Entities.emit_signal(Signals.Entities.FREE_CAMERA_TOGGLED)
	
	if event.is_action_pressed("zoom_in", true) :
		fly_speed += CHANGE_FLY_SPEED_BY
		Signals.Hud.emit_signal(Signals.Hud.FLIGHT_VALUE_SET, fly_speed)
	if event.is_action_pressed("zoom_out", true) :
		fly_speed = max(SLOWEST_POSSIBLE_FLIGHT_SPEED, fly_speed - CHANGE_FLY_SPEED_BY)
		Signals.Hud.emit_signal(Signals.Hud.FLIGHT_VALUE_SET, fly_speed)
	
	#Check if the player wants to switch to first person.
	if event.is_action_pressed("toggle_first_person") && camera.is_current() && allow_first_person :
		if entity.has_node("Model") :
			is_first_person = !is_first_person
			entity.get_node("Model").visible = !is_first_person
			
			#Hud Reticle should be active when in first person mode.
			Signals.Hud.emit_signal(Signals.Hud.SET_FIRST_PERSON, is_first_person)

func _update_cam_pos(delta : float = 0.016667) -> void:
	#The player is in camera fly mode.
	if is_flying :
		var input : Vector3 = Vector3.ZERO
		input.z = int(Input.is_action_pressed("move_forwards")) + -int(Input.is_action_pressed("move_backwards"))
		input.x = int(Input.is_action_pressed("move_left")) + -int(Input.is_action_pressed("move_right"))
		
		#Get input relative to the camera's looking direction.
		var new_input : Vector3 = input
		var forward = camera.global_transform.basis.z
		var left = camera.global_transform.basis.x
		new_input = -(input.z * forward + input.x * left)
		
		input.y = int(Input.is_action_pressed("fly_up")) + -int(Input.is_action_pressed("fly_down"))
		new_input.y = input.y
		
		var velocity : Vector3 = new_input
		velocity *= fly_speed
		velocity *= delta
		
		camera.global_transform.origin += velocity
	
		return
	
	var new_cam_pos
	if is_first_person :
		new_cam_pos = global_transform.origin #+ _get_cam_normal()
		new_cam_pos.y += HEAD_HEIGHT
	else :
		new_cam_pos = global_transform.origin - _get_cam_normal() * dist
	
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
	if is_first_person :
		entity.get_node("Model").show()
		Signals.Hud.emit_signal(Signals.Hud.SET_FIRST_PERSON, false)
	.disable()

func enable():
	#Turn on the aiming reticle if in first person.
	if is_first_person :
		Signals.Hud.emit_signal(Signals.Hud.SET_FIRST_PERSON, true)
	if Network.network_instance.peer_id == entity.owner_peer_id:
		camera.set_current(true)
	.enable()
