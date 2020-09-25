extends AMovementController
class_name KinematicMovement

# Component for kinematic movement
export(float) var initial_jump_velocity = 2.2
export(float) var climb_speed = 1.5
export(float) var movement_speed = 3.2

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
	if is_climbing:
		update_stairs_climbing(0.016, state)
	else:
		update_movement(state)
	update_state(state)
	update_server_values()
	
func update_state(state):
	if is_flying:
		entity.state.state = ActorEntityState.State.FLY
	elif is_jumping or !entity.is_grounded and !is_climbing:
		entity.state.state = ActorEntityState.State.IN_AIR
	elif is_climbing:
		entity.state.state = ActorEntityState.State.CLIMBING
	elif abs(state.linear_velocity.length()) > 0:
		entity.state.state = ActorEntityState.State.MOVING
	elif abs(state.linear_velocity.y) > 0.1 or !entity.is_grounded:
		entity.state.state = ActorEntityState.State.IN_AIR
	else:
		entity.state.state = ActorEntityState.State.IDLE

func rotate_body(state) -> void:
	if is_climbing:
		return
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
		jump_velocity -= Vector3(0, 1.625 * 0.016, 0)
		vel = jump_velocity
		# Update current jump velocity to reflect gravity simulation
		if entity.is_grounded:
			if jump_velocity.y < 0:
				is_jumping = false
		# Debug jump
		if jump_velocity.y <= 0 and dbg_rest_jump_pos.is_equal_approx(Vector3()):
			calculate_debug_values()
	# Actual movement
	elif entity.is_grounded:
		vel = horizontal_vector.normalized() * movement_speed
	else:
		# Gravity simulation
		vel += Vector3.DOWN * 1.6 
	
	state.set_linear_velocity(vel)
	entity.velocity = state.linear_velocity
	
func update_server_values():
	entity.srv_pos = entity.global_transform.origin

func calculate_debug_values():
	dbg_rest_jump_pos = entity.global_transform.origin
	dbg_total_jump_height = dbg_rest_jump_pos.y - dbg_initial_jump_pos.y

### TEMPORARY CLIMBING CODE
# to be moved elsewhere.

func start_climb_stairs(target_stairs) -> void:
	#Do nothing if the player is already in climbing state.
	if entity.state.state == ActorEntityState.State.CLIMBING:
		return
	
#	entity.mode = RigidBody.MODE_KINEMATIC
	
	entity.stairs = target_stairs
	is_climbing = true
	
	#Get which direction I should face when climbing the stairs.
	var kb_pos = entity.global_transform.origin
	entity.climb_look_direction = entity.stairs.get_look_direction(kb_pos)
	
	#Get the closest step to start climbing from.
	for index in entity.stairs.climb_points.size():
		if entity.climb_point == -1 or entity.stairs.climb_points[index].distance_to(kb_pos) < entity.stairs.climb_points[entity.climb_point].distance_to(kb_pos):
			entity.climb_point = index
	
	#Rotate the model to best fit the stairs.
	var a = entity.model.global_transform
	var target_transform = a.looking_at(entity.model.global_transform.origin - entity.climb_look_direction, Vector3(0, 1, 0))
	entity.model.global_transform.basis = target_transform.basis
	
	#Automatically move towards the climbing point horizontally when you first grab on.
#	var flat_velocity = (entity.stairs.climb_points[entity.climb_point] - kb_pos) * 50.0
#	flat_velocity.y = 0.0
#	entity.velocity += flat_velocity
#	entity.velocity += Vector3(0, input_direction * delta * climb_speed, 0)
	entity.global_transform.origin = entity.stairs.climb_points[entity.climb_point]
	entity.global_transform.origin += -entity.climb_look_direction * 0.35

#Stop climbing stairs.
func stop_climb_stairs() -> void :
	is_climbing = false
	entity.climb_point = -1
#	entity.velocity += Vector3(0, 0, 10)
	
	entity.global_transform.origin.y += 0.2
	
	#Move the entitiy forward based on the climbing direction
	var get_off : Vector2 = Vector2.UP.rotated(entity.model.rotation.y)
	entity.global_transform.origin += Vector3(get_off.x * -0.8, 0, get_off.y * -0.8)
	
	#Make myself face the same direction as the camera.
	entity.model.global_transform.basis = entity.global_transform.basis
#	entity.mode = RigidBody.MODE_CHARACTER

func update_stairs_climbing(delta, state):
	var kb_pos = entity.global_transform.origin
	
	#Check for next climb point.
	if entity.climb_point + 1 < entity.stairs.climb_points.size() and kb_pos.y > entity.stairs.climb_points[entity.climb_point].y:
		entity.climb_point += 1
	#Check for previous climb point.
	elif entity.climb_point - 1 >= 0 and kb_pos.y < entity.stairs.climb_points[entity.climb_point - 1].y:
		entity.climb_point -= 1
	
	var input_direction = entity.input.z
	
	if entity.climb_point == entity.stairs.climb_points.size() - 1 and kb_pos.y > entity.stairs.climb_points[entity.climb_point].y and not input_direction <= 0.0:
		# Add the movement velocity using delta to make sure physics are consistent regardless of framerate.
		entity.velocity += horizontal_vector * delta
		
		#Stop climbing at the top when too far away from the stairs.
		if entity.climb_point + 1 >= entity.stairs.climb_points.size() :
			stop_climb_stairs()
	
	#When moving down and at the bottom of the stairs, let go.
	if input_direction < 0.0 and on_ground.is_colliding():
		stop_climb_stairs()
	
#	entity.velocity = entity.move_and_slide(entity.velocity, Vector3.UP, slide)
#	entity.global_transform.origin += Vector3.UP
	
	state.set_linear_velocity(Vector3.UP * climb_speed * entity.input.z)
	entity.velocity = state.linear_velocity
	
	# Update the values that are used for networking.
	entity.srv_pos = entity.global_transform.origin
	entity.srv_vel = entity.velocity
