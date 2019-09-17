extends Camera

func _ready():
	look_direction = rotation_degrees

var look_direction = Vector3()
var max_up_aim_angle = 80.0
var max_down_aim_angle = 80.0
var mouse_sensitivity = 0.10
var velocity = Vector3()
var look_velocity = Vector3()
var mouse_down = false

var velocity_damp = 0.9
var look_acceleration = 0.2
var movement_acceleration = 0.2

func _process(delta):
	if not UIManager.has_ui:
		UIManager.RequestFocus()
	
	var forward_direction = global_transform.basis.z
	var right_direction = global_transform.basis.x
	global_transform.origin += velocity
	
	velocity = velocity * velocity_damp
	look_velocity = look_velocity * velocity_damp
	
	rotation_degrees += look_velocity
	
	if Input.is_action_pressed("left_click"):
		mouse_down = true
	else:
		mouse_down = false
	
	if rotation_degrees.x > max_up_aim_angle:
		rotation_degrees.x = max_up_aim_angle
	elif rotation_degrees.x < -max_down_aim_angle:
		rotation_degrees.x = -max_down_aim_angle
	
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

func _input(event):
	if event is InputEventMouseMotion:
		if mouse_down:
			look_velocity.y -= event.relative.x * mouse_sensitivity * look_acceleration
			look_velocity.x -= event.relative.y * mouse_sensitivity * look_acceleration
	
	if event.is_action_pressed("scroll_up"):
		movement_acceleration = min(2.0, movement_acceleration + 0.05)
		
	if event.is_action_pressed("scroll_down"):
		movement_acceleration = max(0.0, movement_acceleration - 0.05)

func _notification(message): 
	if message == NOTIFICATION_PREDELETE: 
		# Release the focus when this node is being freed.
		UIManager.ReleaseFocus()
