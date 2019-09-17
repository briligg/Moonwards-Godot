extends Spatial

var camera_speed = 5.0
var movement_speed = 30.0
var movement_force = Vector3()
var jump_force = Vector3()
var look_direction = Vector2()
var max_speed = 3.0
var max_up_aim_angle = 55.0
var max_down_aim_angle = 55.0
var movement_direction = Vector3(0,0,0)
var mouse_sensitivity = 0.10
var turn_speed = 5.0
var model_quat = Quat()

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	movement_direction = global_transform.basis.z

func _physics_process(delta):
	var target_transform = $KinematicBody/CameraPivot/CameraPosition.global_transform
	$Camera.global_transform = $Camera.global_transform.interpolate_with(target_transform, delta * camera_speed)
	
	var movement_direction = Vector3()
	var forward_direction = -$Camera.global_transform.basis.z
	forward_direction.y = 0.0
	var right_direction = $Camera.global_transform.basis.x
	right_direction.y = 0.0
	
	if Input.is_action_pressed("move_forwards"):
		movement_direction += forward_direction
	
	if Input.is_action_pressed("move_backwards"):
		movement_direction -= forward_direction
	
	if Input.is_action_pressed("move_right"):
		movement_direction += right_direction
	
	if Input.is_action_pressed("move_left"):
		movement_direction -= right_direction
	
	if (movement_force + movement_direction).length() > max_speed:
		movement_force = (movement_force + movement_direction).normalized() * max_speed
	else:
		movement_force += movement_direction
	
	if Input.is_action_just_pressed("jump") and $KinematicBody.is_on_wall():
		jump_force = Vector3(0.0, 150.0, 0.0)
		$AnimationTree.set("parameters/Transition/current", "Jump")
	
	$KinematicBody.move_and_slide((movement_force * movement_speed * delta) + (jump_force * delta) + (Vector3(0.0, -1.62, 0.0)))
	movement_force *= 0.95
	jump_force *= 0.95
	
	$KinematicBody/CameraPivot.rotation_degrees = Vector3(look_direction.y, look_direction.x, 0)
	
	var model = $KinematicBody/Scene
	if movement_force.length() > 0.2:
		var flat_force = movement_force
		flat_force.y = 0.0
		flat_force = flat_force.normalized()
		if flat_force != Vector3():
			var model_target_transform = model.global_transform.looking_at(model.global_transform.origin - flat_force, Vector3(0, 1, 0))
			model_quat = model_quat.slerp(Quat(model_target_transform.basis), delta * turn_speed)
			model.global_transform.basis = Basis(model_quat)

func _input(event):
	if event.is_action_pressed("scroll_up"):
		$KinematicBody/CameraPivot/CameraPosition.translation.z -= 1.0
		if $KinematicBody/CameraPivot/CameraPosition.translation.z < 0.0:
			$KinematicBody/CameraPivot/CameraPosition.translation.z = 0.0
	
	if event.is_action_pressed("scroll_down"):
		$KinematicBody/CameraPivot/CameraPosition.translation.z += 1.0
	
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
