extends Camera

const MAX_UP_AIM_ANGLE : float = 80.0
const MAX_DOWN_AIM_ANGLE : float = 80.0
const MOUSE_SENSITIVITY : float = 0.10
const VELOCITY_DAMP : float = 0.9
const LOOK_ACCELERATION : float = 0.2

var velocity : Vector3 = Vector3()
var look_velocity : Vector3 = Vector3()
var mouse_down : bool = false
var movement_acceleration : float = 0.2

func _process(delta : float) -> void:
	if not UIManager.has_ui:
		UIManager.request_focus()
	
	var forward_direction = global_transform.basis.z
	var right_direction = global_transform.basis.x
	global_transform.origin += velocity
	
	velocity = velocity * VELOCITY_DAMP
	look_velocity = look_velocity * VELOCITY_DAMP
	
	rotation_degrees += look_velocity
	
	if Input.is_action_pressed("left_click"):
		mouse_down = true
	else:
		mouse_down = false
	
	if rotation_degrees.x > MAX_UP_AIM_ANGLE:
		rotation_degrees.x = MAX_UP_AIM_ANGLE
	elif rotation_degrees.x < -MAX_DOWN_AIM_ANGLE:
		rotation_degrees.x = -MAX_DOWN_AIM_ANGLE
	
	if Input.is_action_pressed("move_forwards"):
		if Input.is_action_pressed("shift"):
			velocity -= Vector3(0, -1, 0) * delta * movement_acceleration
		else:
			velocity -= forward_direction * delta * movement_acceleration
	
	if Input.is_action_pressed("move_backwards"):
		if Input.is_action_pressed("shift"):
			velocity += Vector3(0, -1, 0) * delta * movement_acceleration
		else:
			velocity += forward_direction * delta * movement_acceleration
	
	if Input.is_action_pressed("move_left"):
		velocity -= right_direction * delta * movement_acceleration
	
	if Input.is_action_pressed("move_right"):
		velocity += right_direction * delta * movement_acceleration

func _input(event : InputEvent) -> void:
	if event is InputEventMouseMotion:
		if mouse_down:
			look_velocity.y -= event.relative.x * MOUSE_SENSITIVITY * LOOK_ACCELERATION
			look_velocity.x -= event.relative.y * MOUSE_SENSITIVITY * LOOK_ACCELERATION
	
	if event.is_action_pressed("scroll_up"):
		movement_acceleration = min(2.0, movement_acceleration + 0.05)
		
	if event.is_action_pressed("scroll_down"):
		movement_acceleration = max(0.0, movement_acceleration - 0.05)

func _notification(message : int) -> void:
	if message == NOTIFICATION_PREDELETE: 
		# Release the focus when this node is being freed.
		UIManager.release_focus()