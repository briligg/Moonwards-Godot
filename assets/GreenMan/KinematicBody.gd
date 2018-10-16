extends KinematicBody

var speed = 100
var direction = Vector3()
var direction_r = Vector3()
var gravity = -9.8
var velocity = Vector3()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
func _input(event):
	var _mouse_position = Vector2(0.0, 0.0)
	if event is InputEventMouseMotion:
		_mouse_position = event.relative
		rotate_y(-2*PI/360*0.1*_mouse_position.x)
		get_node("Camera").rotate_x(-2*PI/360*0.1*_mouse_position.y)
		


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	direction = Vector3(0,0,0)
	if Input.is_action_pressed("ui_left"):
		#direction.x -= 1
		rotate_y(2*PI/360)
	if Input.is_action_pressed("ui_right"):
		#direction.x += 1
		rotate_y(-2*PI/360)

	if Input.is_action_pressed("ui_up"):
		direction.z -= 1
	if Input.is_action_pressed("ui_down"):
		direction.z += 1
	direction = (direction.rotated(Vector3(0,1,0), rotation.y)).normalized()
	direction = direction * speed * delta
	
	velocity.y += gravity * delta
	velocity.x = direction.x
	velocity.z = direction.z
	
	velocity = move_and_slide(velocity, Vector3(0, 1, 0))

