extends AMovementController
class_name HumanoidMovement

# Component for kinematic movement
export(float) var initial_jump_velocity = 2.2
export(float) var climb_speed = 1.5
export(float) var movement_speed = 3
export(float) var gravity = 1.625

onready var on_ground : Node = $OnGround
onready var normal_detect : Node = $NormalDetect

# Debug variables
var dbg_initial_jump_pos: Vector3 = Vector3()
var dbg_rest_jump_pos: Vector3 = Vector3()
var dbg_total_jump_height: float = 0.0
var dbg_ground_normal: Vector3 = Vector3()
var dbg_ground_slope: float = 0.0
var dbg_ground_slope_center: float = 0.0
var dbg_speed: float = 0.0

# Input vectors
var horizontal_vector: Vector3 = Vector3.ZERO
var vertical_vector: Vector3 = Vector3.ZERO
var is_jumping: bool = false
var jump_velocity: Vector3 = Vector3.ZERO

# Normal raycast normalized offset multiplier, depending on movement direction
# Basically equal to player radius
var raycast_offset_multipler: float = 0.22
# Multiplier for gravity's effect based on how steep a slope is
var slope_coef_mul: float = 1
#Whether we are currently flying or not.
var is_flying : bool = false

var is_groundcast_enabled: bool = true

#This is the stairs we are climbing's climb point plus one at the top created by us.
var climb_points : Array = []

#Whether I am climbing or not.
# Puppetsync hack for now
puppetsync var is_climbing : bool = false

func _init():
	pass

func _ready() -> void:
	# Add the KinematicBody as collision exception so it doesn't detect the body as a walkable surface.
	on_ground.add_exception(entity)
	normal_detect.add_exception(entity)
	
	Signals.Entities.connect(Signals.Entities.FLY_TOGGLED, self, "_toggle_fly")
	entity.connect("on_forces_integrated", self, "_integrate_forces")

func is_grounded() -> bool:
	if !is_groundcast_enabled:
		return false
	return (on_ground.is_colliding() or $OnGround2.is_colliding() or $OnGround3.is_colliding()
			or $OnGround4.is_colliding() or $OnGround5.is_colliding())

func _integrate_forces(state):
	invoke_network_based("_integrate_server", "_integrate_client", [state])

func _integrate_client(args):
	var phys_state = args[0]
	entity.is_grounded = is_grounded()
	
	# Return as now movement is handled by the anchor component.
	if entity.movement_anchor_data.is_anchored:
		entity.custom_integrator = true
		return
	else:
		entity.custom_integrator = false
	
	entity.global_transform.origin = entity.srv_pos
	entity.velocity = entity.srv_vel
	phys_state.linear_velocity = entity.srv_vel
	rotate_body(phys_state)
	update_anim_state(phys_state)
	
func _integrate_server(args):
	var phys_state = args[0]
	entity.is_grounded = is_grounded()
	# Don't do a thing if you're anchored, stupid...
	# I still feel this needs to be somewhere else, regardless.
	if entity.movement_anchor_data.is_anchored:
		entity.custom_integrator = true
		update_entity_values()
		update_server_values(phys_state)
		return
	else:
		entity.custom_integrator = false
	
	# Just free-falling in the air
	if !entity.is_grounded and !is_jumping and !is_climbing:
		update_entity_values()
		update_server_values(phys_state)
		return
	main_logic_routine(phys_state)
	
func main_logic_routine(phys_state):
	reset_input()
	if self.enabled:
		handle_input()
	rotate_body(phys_state)
	calculate_slope()
	calculate_horizontal(phys_state)
	update_raycasts()
	if entity.is_grounded and vertical_vector.y > 0:
		update_jump_velocity(phys_state)
	if is_climbing:
		update_stairs_climbing(0.016, phys_state)
	else:
		update_movement(phys_state)
	update_entity_values()
	update_anim_state(phys_state)
	update_server_values(phys_state)
#
func update_anim_state(phys_state : PhysicsDirectBodyState):
	if is_flying:
		entity.state.state = ActorEntityState.State.FLY
	elif is_jumping or !entity.is_grounded and !is_climbing:
		entity.state.state = ActorEntityState.State.IN_AIR
	elif is_climbing:
		entity.state.state = ActorEntityState.State.CLIMBING
	elif abs(entity.velocity.length()) > 0:
		entity.state.state = ActorEntityState.State.MOVING
	elif abs(entity.velocity.y) > 0.1 or !entity.is_grounded:
		entity.state.state = ActorEntityState.State.IN_AIR
	else:
		entity.state.state = ActorEntityState.State.IDLE

func rotate_body(_phys_state : PhysicsDirectBodyState) -> void:
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

func calculate_slope():
	dbg_ground_normal = normal_detect.get_collision_normal().normalized()
	var norm2 = $NormalDetect2.get_collision_normal().normalized()
	dbg_ground_slope = rad2deg(acos(dbg_ground_normal.dot(Vector3.UP)))
	dbg_ground_slope_center = + rad2deg(acos(dbg_ground_normal.dot(Vector3.UP)))

func calculate_horizontal(_phys_state : PhysicsDirectBodyState):
	horizontal_vector += entity.input.z * entity.model.transform.basis.z
	horizontal_vector += entity.input.x * entity.model.transform.basis.x

	if dbg_ground_slope > 1:
		var slide_direction = horizontal_vector.slide(dbg_ground_normal)
		horizontal_vector.y = slide_direction.y
		# We'll use this to snap the ground if we're going down
		# To eliminate the jitters caused by on_ground not reading properly
		if sign(horizontal_vector.y) == -1:
			# Gravity, times slope coefficient, times slope coefficient multiplier
			var slope_mul = max(sin(deg2rad(dbg_ground_slope)), 
					sin(deg2rad(dbg_ground_slope_center)))
			horizontal_vector.y += -gravity * slope_mul * slope_coef_mul
		horizontal_vector = horizontal_vector.normalized()

func update_raycasts():
	var vec = horizontal_vector.normalized() * raycast_offset_multipler
	vec.y = 0.3
	normal_detect.transform.origin = vec

func update_jump_velocity(_phys_state : PhysicsDirectBodyState):
	dbg_initial_jump_pos = entity.global_transform.origin
	dbg_rest_jump_pos = Vector3()
	jump_velocity = Vector3()
	jump_velocity.y = initial_jump_velocity
	jump_velocity += horizontal_vector.normalized() * movement_speed
	is_jumping = true
	entity.is_grounded = false
	disable_ground_cast_for_seconds(0.2)
	

func update_movement(phys_state : PhysicsDirectBodyState):
	var vel = Vector3()
	# Jump simulation
	if is_jumping and !entity.is_grounded:
		# Get our character off the ground, such as grounded() is no longer true
		jump_velocity -= Vector3(0, gravity * 0.016, 0)
		vel = jump_velocity
		# Let godot physics take control after we're off the ground
		if !entity.is_grounded:
			is_jumping = false
		# Debug jump
		if jump_velocity.y <= 0 and dbg_rest_jump_pos.is_equal_approx(Vector3()):
			calculate_debug_values()
	# Actual movement
	elif entity.is_grounded:
		vel = horizontal_vector.normalized() * movement_speed
	
	dbg_speed = vel.length()
	
	phys_state.set_linear_velocity(vel)

func update_entity_values():
	entity.velocity = entity.linear_velocity

func update_server_values(phys_state):
	entity.srv_pos = entity.global_transform.origin
	entity.srv_vel = entity.velocity
	
func calculate_debug_values():
	dbg_rest_jump_pos = entity.global_transform.origin
	dbg_total_jump_height = dbg_rest_jump_pos.y - dbg_initial_jump_pos.y

func disable_ground_cast_for_seconds(duration = 0.0):
	if duration != 0.0:
		is_groundcast_enabled = false
		yield(get_tree().create_timer(duration), "timeout")
		is_groundcast_enabled = true

### TEMPORARY CLIMBING CODE
# to be moved elsewhere and possibly reworked.
func start_climb_stairs(target_stairs : VerticalStairs) -> void:
	#Do nothing if the player is already in climbing state.
	if is_climbing:
		return
	
	entity.custom_integrator = true
	entity.stairs = target_stairs
	is_climbing = true
	
	#Get which direction I should face when climbing the stairs.
	var kb_pos = entity.global_transform.origin
	entity.climb_look_direction = entity.stairs.get_look_direction(kb_pos)
	
	#Get the closest step to start climbing from.
	for index in entity.stairs.climb_points.size():
		if entity.climb_point == -1 or entity.stairs.climb_points[index].distance_to(kb_pos) < entity.stairs.climb_points[entity.climb_point].distance_to(kb_pos):
			entity.climb_point = index
	
	#Store the climb points of the stairs but add an imaginary one at the end for dismounting.
	#Do this after getting closest step so we don't initially grab onto imaginary point.
	climb_points = entity.stairs.climb_points
	var t = climb_points[climb_points.size() - 1]
	var new_point : Vector3 = t + (t - climb_points[climb_points.size() - 2])
	climb_points.append(new_point)
	
	#Rotate the model to best fit the stairs.
	var a = entity.global_transform
	var target_transform = a.looking_at(entity.global_transform.origin - entity.climb_look_direction, Vector3(0, 1, 0))
	entity.model.transform.basis = target_transform.basis
	
	#Automatically move towards the climbing point horizontally when you first grab on.
	entity.global_transform.origin = entity.stairs.climb_points[entity.climb_point]
	entity.global_transform.origin += -entity.climb_look_direction * 0.35

#Stop climbing stairs.
# is_stairs_top indicates if the player is at the top (true)
# or the bottom (false) of the stairs.
func stop_climb_stairs(phys_state : PhysicsDirectBodyState, is_stairs_top) -> void :
	is_climbing = false

	if is_stairs_top:
		var push_force = entity.model.transform.basis.z.normalized() * 1.5 + Vector3.UP * 2
		entity.set_linear_velocity(push_force)

	entity.custom_integrator = false
	if is_network_master():
		rset("is_climbing", is_climbing)

#Eventually we need to make this work with delta.
func update_stairs_climbing(_delta : float, phys_state : PhysicsDirectBodyState) -> void :
	#If player jumped, let go of stairs.
	if vertical_vector.y > 0:
		stop_climb_stairs(phys_state, false)
	
	var kb_pos = entity.global_transform.origin
	# Offset from the top of the stairs to climb off when reached
	var top_offset = 2
	#Check for next climb point.
	if entity.climb_point + 1 < entity.stairs.climb_points.size() - top_offset and kb_pos.y > entity.stairs.climb_points[entity.climb_point].y:
		entity.climb_point += 1
	#Check for previous climb point.
	elif entity.climb_point - 1 >= 0 and kb_pos.y < entity.stairs.climb_points[entity.climb_point - 1].y:
		entity.climb_point -= 1
	
	#Make it easier to read which direction we are climbing.
	var input_direction = entity.input.z
	
	#Stop climbing at the top of the stairs.
	if entity.climb_point + 1 >= entity.stairs.climb_points.size() - top_offset and kb_pos.y > entity.stairs.climb_points[entity.climb_point].y and not input_direction <= 0.0:
		stop_climb_stairs(phys_state, true)
		return
	
	#When moving down and at the bottom of the stairs, let go.
	if input_direction < 0.0 and on_ground.is_colliding():
		stop_climb_stairs(phys_state, false)
		return
	
	phys_state.set_linear_velocity(Vector3.UP * climb_speed * entity.input.z)
