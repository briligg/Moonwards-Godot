extends AMovementController
class_name KinematicMovement

# Component for kinematic movement
export(float) var initial_jump_velocity = 4
export(float) var climb_speed = 10
export(float) var movement_speed = 4

# Debug variables
var dbg_initial_jump_pos = Vector3()
var dbg_rest_jump_pos = Vector3()
var dbg_total_jump_height: float = 0.0

# Input vectors
var horizontal_vector: Vector3 = Vector3.ZERO
var vertical_vector: Vector3 = Vector3.ZERO
var is_jumping: bool = false
var jump_velocity: Vector3 = Vector3.ZERO

#Whether we are currently flying or not.
var is_flying : bool = false

onready var on_ground : Node = $OnGround
onready var normal_detect : Node = $NormalDetect
#Whether I am climbing or not.
var is_climbing : bool = false

func _init():
	pass

func _ready() -> void:
	# Add the KinematicBody as collision exception so it doesn't detect the body as a walkable surface.
	on_ground.add_exception(entity)
	normal_detect.add_exception(entity)
	
	Signals.Entities.connect(Signals.Entities.FLY_TOGGLED, self, "_toggle_fly")
	entity.connect("on_forces_integrated", self, "_integrate_forces")

func is_grounded() -> bool:
	return on_ground.is_colliding()

func _integrate_forces(state):
	invoke_network_based("_integrate_server", "_integrate_client", [state])
	
func _integrate_client(args):
	pass
	
func _integrate_server(args):
	var state = args[0]
	entity.is_grounded = is_grounded()
	reset_input()
	handle_input()
	rotate_body(state)
	calculate_horizontal(state)
	if entity.is_grounded and vertical_vector.y > 0:
		update_jump_velocity(state)
	update_movement(state)
#	state.integrate_forces()
	update_state(state)
	update_server_values()
	
func update_state(state):
	if is_flying:
		entity.state.state = ActorEntityState.State.FLY
	elif is_jumping:
		entity.state.state = ActorEntityState.State.IN_AIR
	elif is_climbing:
		entity.state.state = ActorEntityState.State.CLIMBING
	elif state.linear_velocity.length() > 0.1:
		entity.state.state = ActorEntityState.State.MOVING
	elif abs(state.linear_velocity.y) > 0.1 or !entity.is_grounded:
		entity.state.state = ActorEntityState.State.IN_AIR
	else:
		entity.state.state = ActorEntityState.State.IDLE

func rotate_body(state) -> void:
	# Rotate
	var o = entity.global_transform.origin
	var t = entity.look_dir
	var theta = atan2(o.x - t.x, o.z - t.z)
	entity.model.set_rotation(Vector3(0, theta, 0))

func reset_input():
	horizontal_vector = Vector3()
	vertical_vector = Vector3()

func handle_input() -> void:
	# Adding a timeout after the jump makes sure the jump velocity is consistent and not triggered multiple times.
	if entity.state.state != ActorEntityState.State.IN_AIR and entity.input.y > 0:
		vertical_vector.y = 1

func calculate_horizontal(state):
	horizontal_vector += entity.input.z * entity.model.transform.basis.z
	horizontal_vector += entity.input.x * entity.model.transform.basis.x

func update_jump_velocity(state):
	dbg_initial_jump_pos = entity.global_transform.origin
	dbg_rest_jump_pos = Vector3()
	jump_velocity = Vector3()
	jump_velocity.y = initial_jump_velocity
	jump_velocity += horizontal_vector.normalized() * movement_speed
	is_jumping = true

func update_movement(state):
	var vel = Vector3()
	
	# Jump velocity simulation
	if is_jumping:
		vel += jump_velocity
		# Update current jump velocity to reflect gravity simulation
		jump_velocity -= Vector3(0, 1.6 * 0.016, 0)
		if entity.is_grounded:
			if jump_velocity.y < 0:
				is_jumping = false
		# Debug jump
		if jump_velocity.y <= 0 and dbg_rest_jump_pos.is_equal_approx(Vector3()):
			calculate_debug_values()
	# Actual movement
	elif entity.is_grounded:
		vel += horizontal_vector.normalized() * movement_speed
	
	# Gravity simulation
	vel += Vector3.DOWN * 1.6 
	
	state.set_linear_velocity(vel)
	
func update_server_values():
	entity.srv_pos = entity.global_transform.origin

func calculate_debug_values():
	dbg_rest_jump_pos = entity.global_transform.origin
	dbg_total_jump_height = dbg_rest_jump_pos.y - dbg_initial_jump_pos.y
