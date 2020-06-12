extends AMovementController
class_name KinematicMovement
# Component for kinematic movement

export(float) var speed = 25
export(float) var jump_force = 15

# Input vectors
var horizontal_vector: Vector3 = Vector3.ZERO
var vertical_vector: Vector3 = Vector3.ZERO
var ground_normal: Vector3 = Vector3.ZERO

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
	ground_normal = $OnGround.get_collision_normal()

func _process_client(delta):
	# Rotate only on the client
	# The server will adjust accordingly to the velocity vector.
	rotate_body(delta)
#	var o = entity.global_transform.origin
	var t = entity.srv_pos
	var v = entity.srv_vel
	# This needs to be cleaned up
	if not is_network_master():
		entity.velocity = v
		entity.global_transform.origin = t
	update_state()

func _process_server(delta):
	rotate_body(delta)
	
	var velocity = horizontal_vector
	velocity += vertical_vector
	
	#Only start ground normal assisted walking when the character is on the ground and not jumping.
	if entity.is_grounded and not entity.input.y > 0:
		var velocity_direction = horizontal_vector.normalized()
		var slide_direction = velocity_direction.slide(ground_normal)
		horizontal_vector = slide_direction * horizontal_vector.length()
		#Move the raycast towards the movement direction to detect the ground better. Makes the ramps walkable.
		$OnGround.cast_to = (Vector3(0.0, -1.0, 0.0) + velocity_direction).normalized() * 0.5
		
		velocity.x = horizontal_vector.x
		#when the ground normal is steeper than a threshold start adding vertical movement to help the character walk up ramps.
		if ground_normal.angle_to(Vector3(0.0, 1.0, 0.0)) > 0.1:
			velocity.y = horizontal_vector.y
		velocity.z = horizontal_vector.z
	
	#Don't let the character slide off slanted surfaces, but when do slide when no ground is found like edges.
	var slide = horizontal_vector != Vector3.ZERO and entity.is_grounded
	entity.velocity = entity.move_and_slide(velocity * WorldConstants.SCALE, Vector3.UP, slide)
	entity.srv_pos = entity.global_transform.origin
	entity.srv_vel = entity.velocity
	update_state()

func update_state():
	if Vector2(entity.velocity.x, entity.velocity.z).length() > 0.1:
		entity.state.state = ActorEntityState.State.MOVING
	elif abs(entity.velocity.y) > 0.1 or !entity.is_grounded:
		entity.state.state = ActorEntityState.State.IN_AIR
	else:
		entity.state.state = ActorEntityState.State.IDLE


func reset_state() -> void:
	horizontal_vector = Vector3.ZERO
	entity.velocity = Vector3.ZERO

func handle_input() -> void:
	if is_grounded() and entity.input.y > 0:
		vertical_vector = Vector3.UP * jump_force
	
	var forward = entity.model.global_transform.basis.z
	var left = entity.model.global_transform.basis.x
	
	horizontal_vector = (entity.input.z * forward + entity.input.x * left) * speed

func apply_gravity() -> void:
	vertical_vector.y += -1 * WorldConstants.GRAVITY * WorldConstants.SCALE

func rotate_body(_delta: float) -> void:
	# Rotate
	#entity.look_at(entity.look_dir, Vector3.UP)
	var o = entity.global_transform.origin
	var t = entity.look_dir
	var theta = atan2(o.x - t.x, o.z - t.z)
	entity.model.set_rotation(Vector3(0, theta, 0))
