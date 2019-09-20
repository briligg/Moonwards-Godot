extends Spatial

const CAMERA_SPEED : float = 5.0
const MOVEMENT_SPEED : float = 30.0
const MAX_SPEED : float = 3.0
const MAX_UP_AIM_ANGLE : float = 55.0
const MAX_DOWN_AIM_ANGLE : float = 55.0
const MOUSE_SENSITIVITY : float = 0.10
const TURN_SPEED : float = 5.0

onready var camera_position : Node = $KinematicBody/CameraPivot/CameraPosition
onready var camera : Node = $Camera
onready var animation_tree : Node = $AnimationTree
onready var model : Node = $KinematicBody/Scene
onready var kinematic_body : Node = $KinematicBody
onready var camera_pivot : Node = $KinematicBody/CameraPivot

var _movement_force : Vector3 = Vector3()
var _jump_force : Vector3 = Vector3()
var _look_direction : Vector2 = Vector2()
var _movement_direction : Vector3 = Vector3(0,0,0)
var _model_quat : Quat = Quat()

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	_movement_direction = global_transform.basis.z

func _physics_process(delta : float) -> void:
	var target_transform = camera_position.global_transform
	camera.global_transform = camera.global_transform.interpolate_with(target_transform, delta * CAMERA_SPEED)
	
	var _movement_direction = Vector3()
	var forward_direction = -camera.global_transform.basis.z
	forward_direction.y = 0.0
	var right_direction = camera.global_transform.basis.x
	right_direction.y = 0.0
	
	if Input.is_action_pressed("move_forwards"):
		_movement_direction += forward_direction
	
	if Input.is_action_pressed("move_backwards"):
		_movement_direction -= forward_direction
	
	if Input.is_action_pressed("move_right"):
		_movement_direction += right_direction
	
	if Input.is_action_pressed("move_left"):
		_movement_direction -= right_direction
	
	if (_movement_force + _movement_direction).length() > MAX_SPEED:
		_movement_force = (_movement_force + _movement_direction).normalized() * MAX_SPEED
	else:
		_movement_force += _movement_direction
	
	if Input.is_action_just_pressed("jump") and kinematic_body.is_on_wall():
		_jump_force = Vector3(0.0, 150.0, 0.0)
		animation_tree.set("parameters/Transition/current", "Jump")
	
	var movement_velocity = _movement_force * MOVEMENT_SPEED * delta
	var jump_velocity = _jump_force * delta
	var gravity_velocity = Vector3(0.0, -1.62, 0.0)
	kinematic_body.move_and_slide(movement_velocity + jump_velocity + gravity_velocity)
	
	_movement_force *= 0.95
	_jump_force *= 0.95
	
	camera_pivot.rotation_degrees = Vector3(_look_direction.y, _look_direction.x, 0)
	
	if _movement_force.length() > 0.2:
		var flat_force = _movement_force
		flat_force.y = 0.0
		flat_force = flat_force.normalized()
		if flat_force != Vector3():
			var model_target_transform = model.global_transform.looking_at(model.global_transform.origin - flat_force, Vector3(0, 1, 0))
			_model_quat = _model_quat.slerp(Quat(model_target_transform.basis), delta * TURN_SPEED)
			model.global_transform.basis = Basis(_model_quat)

func _input(event : InputEvent) -> void:
	if event.is_action_pressed("scroll_up"):
		camera_position.translation.z -= 1.0
		if camera_position.translation.z < 0.0:
			camera_position.translation.z = 0.0
	
	if event.is_action_pressed("scroll_down"):
		camera_position.translation.z += 1.0
	
	if (event is InputEventMouseMotion):
		_look_direction.x -= event.relative.x * MOUSE_SENSITIVITY
		_look_direction.y -= event.relative.y * MOUSE_SENSITIVITY
		
		if _look_direction.x > 360:
			_look_direction.x = 0
		elif _look_direction.x < 0:
			_look_direction.x = 360
		if _look_direction.y > MAX_UP_AIM_ANGLE:
			_look_direction.y = MAX_UP_AIM_ANGLE
		elif _look_direction.y < -MAX_DOWN_AIM_ANGLE:
			_look_direction.y = -MAX_DOWN_AIM_ANGLE