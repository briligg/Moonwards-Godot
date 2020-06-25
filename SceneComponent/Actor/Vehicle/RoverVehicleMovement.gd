extends AMovementController

puppet var wheels : Array

#var wheels : Array
onready var default_stiffness = 1

enum JumpState {
	None,
	Charging,
	Released,
	Reset,
}

var jump_state = JumpState.None

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

func _process_server(_delta):
	translate_input()
	entity.engine_force = entity.input.z * 100000
	wheels[0].steering = entity.input.x * 60
	wheels[1].steering = entity.input.x * 60
	wheels[4].steering = -entity.input.x * 60
	wheels[5].steering = -entity.input.x * 60
	process_jump()
	entity.srv_pos = entity.global_transform.origin
	entity.srv_basis = entity.global_transform.basis

func process_jump() -> void:
	if jump_state == JumpState.Charging:
		for wheel in wheels:
			wheel.suspension_stiffness = .1
	elif jump_state == JumpState.Released:
		for wheel in wheels:
			wheel.suspension_stiffness = 7
			wheel.suspension_stiffness = 7
		jump_state = JumpState.Reset
	elif jump_state == JumpState.Reset:
		for wheel in wheels:
			wheel.suspension_stiffness = default_stiffness
		jump_state = JumpState.None

func _process_client(_delta):
	if not is_network_master():
		entity.global_transform.origin = entity.srv_pos
		entity.global_transform.basis = entity.srv_basis

#func _process_client(_delta):
#	entity.global_transform.origin = entity.srv_pos
#	pass

func translate_input() -> void:
	if entity.input.y == 1:
		jump_state = JumpState.Charging
	elif jump_state == JumpState.Charging and entity.input.y == 0:
		jump_state = JumpState.Released
