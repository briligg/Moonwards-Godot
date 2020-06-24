extends AMovementController

onready var wheels : Array

#var wheels : Array
onready var default_stiffness = 0.5

enum JumpState {
	None,
	Charging,
	Releasing,
}
var is_charging_jump = 0
# Input vectors
var forward: float
var vertical: float

func _ready():
	wheels = [
	entity.get_node("LeftFrontWheel"),
	entity.get_node("RightFrontWheel"),
	entity.get_node("LeftMidWheel"),
	entity.get_node("RightMidWheel"),
	entity.get_node("LeftBackWheel"),
	entity.get_node("RightBackWheel")
]

func _process(_delta):
	handle_input()

func _physics_process(_delta):
	entity.engine_force = forward * 1000000
	wheels[0].steering = vertical * 45
	wheels[1].steering = vertical * 45
	wheels[4].steering = -vertical * 45
	wheels[5].steering = -vertical * 45
	if is_charging_jump == 1:
		for wheel in wheels:
			wheel.suspension_stiffness = 0
		is_charging_jump = 2
	elif is_charging_jump == 2:
		is_charging_jump = 0
		for wheel in wheels:
			wheel.suspension_stiffness = 5

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
	
	if Input.is_action_pressed("jump"):
		is_charging_jump = 1
