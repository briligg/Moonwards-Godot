# Inspired by Guillaume Roy's script
# https://github.com/TheFamousRat/GodotUtility/blob/master/3d/3D%20Cameras/3rdPersonCamera.gd
extends AComponent
class_name CameraController

const JOYPAD_DEADZONE = 0.09

onready var camera: Camera = $Camera
onready var pivot: Spatial = $Pivot

export(bool) var overriden = false #Use for bots only
export(bool) var allow_first_person = false
export(float) var dist: float = .5
export(float) var max_pitch: float = 55
export(float) var max_pitch_fp_increase = 30
export(float) var cull_col_distance: float = 0.1
onready var excluded_cull_bodies = [entity]

#What max pitch value we started with.
onready var max_pitch_start : float = max_pitch

var mouse_sensitivity: float = 0.1
var yaw: float = 0.0
var pitch: float = 0.0

#This determines if I am in fps mode.
var is_first_person : bool = false
const HEAD_HEIGHT : float = 0.8

#If I should respond to the mouse or not.
var mouse_respond : bool = true

#True when the mouse has been captured.
var mouse_just_toggled : bool = false

#Determines if I should freely fly or not.
var _is_flying : bool = false 
#How fast the player is flying.
var fly_speed : float = 40

const CHANGE_FLY_SPEED_BY : float = 2.0
const SLOWEST_POSSIBLE_FLIGHT_SPEED : float = 0.05



func _init().("Camera", true):
	mouse_respond = Helpers.is_mouse_captured()
	
func _ready() -> void:
	#Stop camera rotation when mouse is active.
	Signals.Menus.connect(Signals.Menus.SET_MOUSE_TO_CAPTURED, self, "_respond_to_mouse")
	
	yaw = 0.0
	pitch = 0.0
	_update_cam_pos()
	camera.set_as_toplevel(true)

func _process(delta: float) -> void:
	#Set the camera back to regular mode if it is not the current camera.
	if not camera.is_current() :
		#Turn on the model if we were first person.
		if allow_first_person :
			entity.get_node("Model").visible = true
		return
	
	#Turn off the model if we are in first person mode.
	if is_first_person :
		entity.get_node("Model").visible = false
	
	var _new_rot = Vector3(deg2rad(pitch), deg2rad(yaw), 0.0)
	if not overriden && mouse_respond :
		camera.set_rotation(_new_rot)
	_update_cam_pos()
	
	if not _is_flying and not overriden:
		entity.look_dir = global_transform.origin - _get_cam_normal() * dist
		
	var joypad_vec = Vector2()
	if Input.get_connected_joypads().size() > 0:

		if OS.get_name() == "Windows":
			joypad_vec = Vector2(Input.get_joy_axis(0, 2), Input.get_joy_axis(0, 3))
		elif OS.get_name() == "X11":
			joypad_vec = Vector2(Input.get_joy_axis(0, 3), Input.get_joy_axis(0, 4))
		elif OS.get_name() == "OSX":
			joypad_vec = Vector2(Input.get_joy_axis(0, 3), Input.get_joy_axis(0, 4))

		if joypad_vec.length() < JOYPAD_DEADZONE:
			joypad_vec = Vector2(0, 0)
		else:
			joypad_vec = joypad_vec.normalized() * ((joypad_vec.length() - JOYPAD_DEADZONE) / (1 - JOYPAD_DEADZONE))
		
		if MwInput.is_chat_active:
			return
		if joypad_vec.length() > JOYPAD_DEADZONE:
			yaw = fmod(yaw - joypad_vec.x * mouse_sensitivity * (800*delta), 360.0)
			pitch = max(min(pitch - joypad_vec.y * mouse_sensitivity  * (800*delta), max_pitch), -max_pitch)

func _input(event):
	if MwInput.is_chat_active:
		return

	var mouse_vec : Vector2 = Vector2.ZERO
	
	if event is InputEventJoypadMotion:
		mouse_vec = Vector2(mouse_sensitivity, mouse_sensitivity)
		mouse_vec.y -= event.get_action_strength("look_up") 
		mouse_vec.y += event.get_action_strength("look_down") 
		mouse_vec.x += event.get_action_strength("look_right") 
		mouse_vec.x -= event.get_action_strength("look_left") 
		
	if event is InputEventMouseMotion :
		if not mouse_just_toggled :
			mouse_vec = event.get_relative()
	
	#Check to see if the player has started camera free fly.
	elif event.is_action_pressed("toggle_camera_fly") :
		_is_flying = !_is_flying
		
		Signals.Entities.emit_signal(Signals.Entities.FREE_CAMERA_SET, _is_flying)
	
	yaw = fmod(yaw - mouse_vec.x * mouse_sensitivity, 360.0)
	pitch = max(min(pitch - mouse_vec.y * mouse_sensitivity , max_pitch), -max_pitch)
	#Change flight speed when in flight mode.
	if _is_flying :
		if event.is_action_pressed("zoom_in", true) :
			fly_speed += CHANGE_FLY_SPEED_BY
			Signals.Hud.emit_signal(Signals.Hud.FLIGHT_VALUE_SET, fly_speed)
		if event.is_action_pressed("zoom_out", true) :
			fly_speed = max(SLOWEST_POSSIBLE_FLIGHT_SPEED, fly_speed - CHANGE_FLY_SPEED_BY)
			Signals.Hud.emit_signal(Signals.Hud.FLIGHT_VALUE_SET, fly_speed)
	
	#Check if the player wants to switch to first person.
	if event.is_action_pressed("toggle_first_person") && camera.is_current() && allow_first_person :
		if entity.has_node("Model") :
			_set_first_person(!is_first_person)

#Called by signal. If true, do not rotate the camera.
func _respond_to_mouse(mouse_active : bool) -> void :
	mouse_respond = mouse_active
	mouse_just_toggled = !mouse_active
	if mouse_just_toggled :
		yield(get_tree().create_timer(0.3), "timeout")

func _update_cam_pos(delta : float = 0.016667) -> void:
	#The player is in camera fly mode.
	if _is_flying :
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
		
		#Make the camera higher if a collision is making us zoom in.
		var inside_body : Vector3 = entity.global_transform.origin
		inside_body.y = 0
		var cam_pos_holder : Vector3 = new_cam_pos
		cam_pos_holder.y = 0
		new_cam_pos.y += HEAD_HEIGHT - (((max(0.01,cam_pos_holder.distance_to(inside_body)) / dist)) * HEAD_HEIGHT)

	camera.global_transform.origin = new_cam_pos
	pass

#Set whether we are in first person or not.
func _set_first_person(become_first_person : bool) -> void :
	is_first_person = become_first_person
	entity.get_node("Model").visible = !become_first_person
	
	#Increase the amount of possible pitch
	if become_first_person :
		max_pitch = max_pitch_start + max_pitch_fp_increase
	else :
		max_pitch = max_pitch_start
	
	#Hud Reticle should be active when in first person mode.
	Signals.Hud.emit_signal(Signals.Hud.SET_FIRST_PERSON, is_first_person)

# Ray normal from the exact center of the viewport
func _get_cam_normal() -> Vector3:
	return camera.project_ray_normal(get_viewport().get_visible_rect().size * 0.5)
	
func disable():
	Log.debug(self, "disable", get_parent().name)
	if is_first_person :
		_set_first_person(false)
	.disable()

func enable():
	#Turn on the aiming reticle if in first person.
	Log.debug(self, "enable", get_parent().name)
	if is_first_person :
		_set_first_person(true)
	if Network.network_instance.peer_id == entity.owner_peer_id:
		camera.set_current(true)
	.enable()
