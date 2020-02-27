extends Spatial

const MOVEMENT_SPEED : float = 10.0
const DOCKING_SPEED : float = 20.0
const MAX_SPEED : float = 3.0
const TURN_SPEED : float = 0.4
const MIN_TURN_SPEED : float = 0.05
const MAX_TURN_SPEED : float = 0.051

onready var animation_tree : AnimationTree = $KinematicBody/AnimationTree
onready var model : Node = $KinematicBody/AthleteRover
onready var kinematic_body : Node = $KinematicBody
onready var root_bone_attachment : BoneAttachment = $KinematicBody/AthleteRover/LegsArmature001/Skeleton/RootBoneAttachment
onready var attachment_position : Spatial = $KinematicBody/AthleteRover/LegsArmature001/Skeleton/RootBoneAttachment/PassengerPodPlaceholder

export(NodePath) var pod_path
onready var pod = get_node(pod_path)
export(NodePath) var nav_path
onready var navigation : Navigation = get_node(nav_path)

const idle = 0
const moving = 1
const docked = 2
const undocking = 3
const waiting = 4
const retrieve_pod = 5
const deliver_pod = 6
const done = 7
const placing_pod = 8
const picking_up_pod = 9

const ride_low = 0
const ride_medium = 1
const ride_high = 2

var state = idle

var _movement_force : Vector3 = Vector3()
var _look_direction : Vector2 = Vector2()
var _movement_direction : Vector3 = Vector3(0,0,0)
var _kb_basis : Basis = Basis()
var _target_location : Transform = Transform()
var _nav_targets : PoolVector3Array = PoolVector3Array()
var _turn_tolerance : float = 0.01
var _move_tolerance : float = 0.01
var _at_target_height : bool = false
var _current_height : float = 0.0
var _target_height : float = 0.0
var _height_movement_speed : float = 0.25

func _ready() -> void:
	_movement_direction = global_transform.basis.z

func _physics_process(delta : float) -> void:
	_update_height(delta)
	_update_state(delta)

func _set_target_height(var new_target_height):
	_at_target_height = false
	_target_height = new_target_height

func _update_height(delta):
	if _current_height < _target_height:
		_current_height += delta * _height_movement_speed
		animation_tree.set("parameters/RideHeight/blend_amount", _current_height)
	elif _current_height > _target_height:
		_current_height -= delta * _height_movement_speed
		animation_tree.set("parameters/RideHeight/blend_amount", _current_height)
	
	if _current_height == _target_height:
		_at_target_height = true
	elif abs(_current_height - _target_height) < 0.001:
		_current_height = _target_height
		animation_tree.set("parameters/RideHeight/blend_amount", _current_height)

func _update_state(delta : float) -> void:
	if state == idle:
		if pod != null:
			#Go get the pod if assigned one.
			_calculate_path(pod.body.global_transform)
			state = retrieve_pod
	elif state == done:
		pass
	elif state == retrieve_pod:
		if _update_movement(delta):
			if !pod.rover_present:
				pod.rover_present = true
			if pod.ready_to_leave:
				_set_target_height(0.0)
				state = picking_up_pod
	elif state == picking_up_pod:
		if abs(attachment_position.global_transform.origin.y - pod.body.global_transform.origin.y) < 0.01 or _at_target_height:
			var old_transform = pod.body.global_transform
			pod.body.get_parent().remove_child(pod.body)
			root_bone_attachment.add_child(pod.body)
			pod.body.global_transform = old_transform
			state = docked
	elif state == docked:
		_set_target_height(1.0)
		yield(get_tree().create_timer(2.0), "timeout")
		_calculate_path(pod.target_transform)
		state = deliver_pod
	elif state == deliver_pod:
		if _update_movement(delta):
			_set_target_height(0.0)
			state = placing_pod
	elif state == placing_pod:
		_update_movement(delta)
		if abs(_target_location.origin.y - pod.body.global_transform.origin.y) < 0.01 or _at_target_height:
			var old_transform = pod.body.global_transform
			root_bone_attachment.remove_child(pod.body)
			pod.add_child(pod.body)
			pod.body.global_transform = old_transform
			pod.delivered()
			pod.rover_present = false
			_set_target_height(1.0)
			state = idle

func _calculate_path(new_target_location : Transform):
	_target_location = new_target_location
	var starting_point = navigation.get_closest_point(kinematic_body.global_transform.origin)
	var end_point = navigation.get_closest_point(_target_location.origin)
	
	_nav_targets = navigation.get_simple_path(starting_point, end_point, true)

func _check_equal_approx(var a : Basis, var b : Basis):
	if(_check_equal_approx_vector3(a.x, b.x, _turn_tolerance) && _check_equal_approx_vector3(a.y, b.y, _turn_tolerance) && _check_equal_approx_vector3(a.z, b.z, _turn_tolerance)):
		return true
	else:
		return false

func _check_equal_approx_vector3(var a : Vector3, var b : Vector3, var tolerance : float) -> bool:
	if(_check_equal_approx_float(a.x, b.x, tolerance) && _check_equal_approx_float(a.y, b.y, tolerance) && _check_equal_approx_float(a.z, b.z, tolerance)):
		return true
	else:
		return false

func _check_equal_approx_float(var a : float, var b : float, var tolerance : float) -> bool:
	return abs(a - b) < tolerance;

func _update_movement(delta : float) -> bool:
	if _nav_targets.size() <= 1:
		_turn_tolerance = 0.003
		_move_tolerance = 0.05
	else:
		_turn_tolerance = 0.05
		_move_tolerance = 0.3
		
	if _nav_targets.empty():
		_kb_basis = _kb_basis.slerp(_target_location.basis, clamp(delta * TURN_SPEED, MIN_TURN_SPEED, MAX_TURN_SPEED))
		model.global_transform.basis = _kb_basis
		
		_movement_direction = (_target_location.origin - kinematic_body.global_transform.origin).normalized()
		_movement_direction.y = 0.0
		var movement_velocity = _movement_direction * DOCKING_SPEED * delta
		kinematic_body.move_and_slide(movement_velocity)
		
		if _check_equal_approx(_kb_basis, _target_location.basis):
			return true
		else:
			return false
	
	_movement_direction = (_nav_targets[0] - kinematic_body.global_transform.origin).normalized()
	_movement_direction.y = 0.0
	
	if (_movement_force + _movement_direction).length() > MAX_SPEED:
		_movement_force = (_movement_force + _movement_direction).normalized() * MAX_SPEED
	else:
		_movement_force += _movement_direction
	
	var movement_velocity = _movement_force * MOVEMENT_SPEED * delta
	var gravity_velocity = Vector3(0.0, -1.62, 0.0)
	kinematic_body.move_and_slide(movement_velocity + gravity_velocity)
	
	_movement_force *= 0.95
	
	var current_position_on_navmesh = navigation.get_closest_point(kinematic_body.global_transform.origin)
	if _nav_targets[0].distance_to(current_position_on_navmesh) < _move_tolerance:
		_nav_targets.remove(0)
	
	var flat_force = _movement_force
	flat_force.y = 0.0
	flat_force = flat_force.normalized()
	if flat_force != Vector3():
		var target_transform = model.global_transform.looking_at(model.global_transform.origin - flat_force, Vector3(0, 1, 0))
		_kb_basis = _kb_basis.slerp(target_transform.basis, clamp(delta * TURN_SPEED, MIN_TURN_SPEED, MAX_TURN_SPEED))
		model.global_transform.basis = _kb_basis
	
	return false
