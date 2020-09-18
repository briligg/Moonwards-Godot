extends AMovementController
class_name KinematicMovement

# Component for kinematic movement
export(float) var on_ground_speed = 4
export(float) var in_air_speed = 3
export(float) var jump_force = 250

export(float) var climb_speed = 10
export(float) var speed = 30

# Input vectors
var horizontal_vector: Vector3 = Vector3.ZERO
var vertical_vector: Vector3 = Vector3.ZERO
var ground_normal: Vector3 = Vector3.UP
var jump_timeout: float
var old_normal : Vector3 = Vector3.DOWN

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

func _physics_process(_delta: float) -> void:
	handle_input(_delta)
	entity.is_grounded = is_grounded()
	# Only get the ground normal if the Raycast is colliding with something or else we get weird values.
	if on_ground.is_colliding():
		ground_normal = on_ground.get_collision_normal()

func _process_client(delta: float) -> void:
	# Rotate only on the client
	# The server will adjust accordingly to the velocity vector.
	rotate_body(delta)
	var t = entity.srv_pos
	var v = entity.srv_vel
	# This needs to be cleaned up
	if not is_network_master():
		entity.velocity = v
		entity.global_transform.origin = t
	update_state()

func _process_server(delta: float) -> void:
	rotate_body(delta)
	update_movement(delta)
	update_state()

func _integrate_forces(state):
	handle_input(0)
	state.set_linear_velocity(horizontal_vector * on_ground_speed)
	state.linear_velocity = state.linear_velocity + Vector3.DOWN * 1.6
	state.integrate_forces()
	pass
	
func update_state():
	if is_flying :
		entity.state.state = ActorEntityState.State.FLY
	elif !entity.is_grounded and !is_climbing:
		entity.state.state = ActorEntityState.State.IN_AIR
	elif is_climbing :
		entity.state.state = ActorEntityState.State.CLIMBING
	elif Vector2(entity.velocity.x, entity.velocity.z).length() > 0.1:
		entity.state.state = ActorEntityState.State.MOVING
	elif abs(entity.velocity.y) > 0.1 or !entity.is_grounded:
		entity.state.state = ActorEntityState.State.IN_AIR
	else:
		entity.state.state = ActorEntityState.State.IDLE


func rotate_body(_delta: float) -> void:
	# Rotate
#	if entity.state.state == ActorEntityState.State.CLIMBING:
#		return
#	else:
#		var o = entity.global_transform.origin
#		var t = entity.look_dir
#		var theta = atan2(o.x - t.x, o.z - t.z)
#		entity.set_rotation(Vector3(0, theta, 0))
	pass

func handle_input(delta : float) -> void:
	# Adding a timeout after the jump makes sure the jump velocity is consistent and not triggered multiple times.
	if(jump_timeout > 0.0 and on_ground):
		jump_timeout -= delta
	elif entity.state.state != ActorEntityState.State.IN_AIR and entity.input.y > 0:
		entity.velocity += Vector3.UP * jump_force * delta
		jump_timeout = 2.0
	
	var forward = entity.model.global_transform.basis.z
	var left = entity.model.global_transform.basis.x
	
	var _speed = on_ground_speed
	
	horizontal_vector = (entity.input.z * forward + entity.input.x * left)


func update_movement(delta):
	pass
