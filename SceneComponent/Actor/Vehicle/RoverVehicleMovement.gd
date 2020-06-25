extends AMovementController

onready var wheels : Array

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
	entity.connect("_integrate_forces_fired", self, "_integrate_forces")

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

func _integrate_forces(state):
	if !get_tree().network_peer:
		return
	if get_tree().is_network_server() and entity.owner_peer_id == get_tree().get_network_unique_id():
		pass
	elif get_tree().is_network_server():
		pass
	else:
		entity.global_transform.origin = entity.srv_pos
		entity.global_transform.basis = entity.srv_basis
		
	state.integrate_forces()

#func _process_client(_delta):
#	entity.global_transform.origin = entity.srv_pos
#	pass

func translate_input() -> void:
	if entity.input.y == 1:
		jump_state = JumpState.Charging
	elif jump_state == JumpState.Charging and entity.input.y == 0:
		jump_state = JumpState.Released
