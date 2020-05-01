extends AMovementController
class_name KinematicMovement
# Component for kinematic movement

export(float) var speed = 5
export(float) var jump_force = 9

# Input vectors
var horizontal_vector: Vector3 = Vector3.ZERO
var vertical_vector: Vector3 = Vector3.ZERO

func _init():
	pass

func _ready():
	$OnGround.add_exception(entity)
	pass

func is_grounded() -> bool:
	return $OnGround.is_colliding()

func _physics_process(_delta):
	reset_state()
	handle_input()
	apply_gravity()
#	move_body(delta)
	entity.is_grounded = is_grounded()

func _process_client(delta):
	# Rotate only on the client
	# The server will adjust accordingly to the velocity vector.
	rotate_body(delta)
	var o = entity.global_transform.origin
	var t = entity.srv_pos
	# This needs to be cleaned up
	if not is_network_master():
		entity.velocity = (t - o)
		entity.global_transform.origin = t
	update_state()

func _process_server(delta):
	rotate_body(delta)
	# If server, we set the authoritative pos to be beamed
	var v = horizontal_vector
	v += vertical_vector
	entity.velocity = entity.move_and_slide(v * WorldConstants.SCALE, Vector3.UP)
	entity.srv_pos = entity.global_transform.origin
	update_state()

func update_state():
	if entity.velocity.x != 0:
		entity.state.state = ActorEntityState.State.MOVING
	if entity.velocity.y != 0:
		entity.state.state = ActorEntityState.State.IN_AIR
	if (entity.velocity == Vector3.ZERO 
			and is_grounded() 
			and horizontal_vector == Vector3.ZERO
			and vertical_vector == Vector3.ZERO):
		entity.state.state = ActorEntityState.State.IDLE


func reset_state() -> void:
	horizontal_vector = Vector3.ZERO
	entity.velocity = Vector3.ZERO
	# Reset gravity accel only if we're on the floor.
	if is_grounded():
		vertical_vector = Vector3.ZERO

func handle_input() -> void:

	if is_grounded() and entity.input.y > 0:
		vertical_vector = Vector3.UP * jump_force
	horizontal_vector = Vector3(entity.input.x, 0, entity.input.z).normalized() * speed

func apply_gravity() -> void:
	if not is_grounded():
		vertical_vector.y += -1 * WorldConstants.GRAVITY * WorldConstants.SCALE

func rotate_body(_delta: float) -> void:
	# Rotate
	#entity.look_at(entity.look_dir, Vector3.UP)
	var o = entity.global_transform.origin
	var t = entity.look_dir
	var theta = atan2(o.x - t.x, o.z - t.z)
	entity.set_rotation(Vector3(0, theta, 0))
