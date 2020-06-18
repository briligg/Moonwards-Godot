extends AMovementController

export(Array, NodePath) var wheels

# Input vectors
var forward: float
var vertical: float

func _process(_delta):
	handle_input()

func _physics_process(_delta):
	entity.engine_force = forward * 5000
	entity.steering = vertical * 45

func handle_input() -> void:
		
	if Input.is_action_pressed("move_forwards"):
		forward = 1
	elif Input.is_action_pressed("move_backwards"):
		forward = -1
	else:
		forward = 0
	
	if Input.is_action_pressed("move_left"):
		vertical = 1
	elif Input.is_action_pressed("move_right"):
		vertical = -1
	else:
		vertical = 0
