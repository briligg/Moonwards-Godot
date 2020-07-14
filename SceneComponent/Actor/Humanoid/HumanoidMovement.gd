extends AMovementController
class_name KinematicMovement

# Component for kinematic movement
export(float) var on_ground_speed = 25
export(float) var in_air_speed = 3
export(float) var jump_force = 250

# Input vectors
var horizontal_vector: Vector3 = Vector3.ZERO
var ground_normal: Vector3 = Vector3.UP
var jump_timeout: float
var old_normal : Vector3 = Vector3.DOWN

onready var on_ground : Node = $OnGround
onready var normal_detect : Node = $NormalDetect

func _ready() -> void:
	# Add the KinematicBody as collision exception so it doesn't detect the body as a walkable surface.
	on_ground.add_exception(entity)
	normal_detect.add_exception(entity)

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
	
	var movement_direction = horizontal_vector.normalized()
	var _velocity_direction = entity.velocity.normalized()
	var normal = normal_detect.get_collision_normal()
	
	# Use the normal of the ground detect if the normal detect isn't colliding.
	if not normal_detect.is_colliding():
		normal = on_ground.get_collision_normal()
	# Move the raycast towards the movement direction to detect the ground better. Makes the ramps walkable.
	on_ground.cast_to = (normal * -2.0 + movement_direction).normalized() * 0.5
	
	# Only start ground normal assisted walking when the character is on the ground.
	if entity.state.state != ActorEntityState.State.IN_AIR:
		var slide_direction = movement_direction.slide(normal)
		var adjusted_horizontal_vector = slide_direction * horizontal_vector.length()
		
		# When the ground normal is steeper than a threshold start adding vertical movement to help the character walk up ramps.
		if ground_normal.angle_to(Vector3(0.0, 1.0, 0.0)) > 0.1:
			horizontal_vector.y = adjusted_horizontal_vector.y
		horizontal_vector.z = adjusted_horizontal_vector.z
		horizontal_vector.x = adjusted_horizontal_vector.x
		
		# When the ground normal changes suddenly, retarget the velocity so it's flat to the ground.
		if jump_timeout <= 0.0 and (old_normal - normal).length() > 0.1:
			old_normal = normal
			# This makes the character snap to the ground normal and not shoot off a ramp.
			entity.velocity = entity.velocity.slide(normal)
	
	# Don't let the character slide off slanted surfaces, but do slide when no ground is found, like edges.
	var slide = horizontal_vector != Vector3.ZERO and entity.is_grounded
	
	# Add the movement velocity using delta to make sure physics are consistent regardless of framerate.
	entity.velocity += horizontal_vector * delta
	# Apply the gravity towards the down direction.
	entity.velocity += (WorldConstants.GRAVITY) * Vector3.DOWN * delta
	
	# TODO the stop_on_slope is ignored in Godot 3.2, check if 4.0 fixes this or create workaround.
	entity.velocity = entity.move_and_slide(entity.velocity, Vector3.UP, slide)
	
	# Add some velcity damping when on the floor, aka friction.
	if entity.state.state != ActorEntityState.State.IN_AIR:
		entity.velocity *= 0.95
	else:
		# A very small amount of air resistance.
		entity.velocity *= 0.999
	
	# Update the values that are use for networking.
	entity.srv_pos = entity.global_transform.origin
	entity.srv_vel = entity.velocity
	update_state()

func update_state():
	if !entity.is_grounded:
		entity.state.state = ActorEntityState.State.IN_AIR
	elif Vector2(entity.velocity.x, entity.velocity.z).length() > 0.1:
		entity.state.state = ActorEntityState.State.MOVING
	else:
		entity.state.state = ActorEntityState.State.IDLE

func handle_input(delta : float) -> void:
	# Adding a timeout after the jump makes sure the jump velocity is consistent and not triggered multiple times.
	if(jump_timeout > 0.0 and on_ground):
		jump_timeout -= delta
	elif entity.state.state != ActorEntityState.State.IN_AIR and entity.input.y > 0:
		entity.velocity += Vector3.UP * jump_force * delta
		jump_timeout = 2.0
	
	var forward = entity.model.global_transform.basis.z
	var left = entity.model.global_transform.basis.x
	
	var speed = on_ground_speed
	# Use a smaller movement speed when the character is in the air.
	if entity.state.state == ActorEntityState.State.IN_AIR:
		speed = in_air_speed
	
	horizontal_vector = (entity.input.z * forward + entity.input.x * left) * speed

func rotate_body(_delta: float) -> void:
	# Rotate
	#entity.look_at(entity.look_dir, Vector3.UP)
	var o = entity.global_transform.origin
	var t = entity.look_dir
	var theta = atan2(o.x - t.x, o.z - t.z)
	entity.model.set_rotation(Vector3(0, theta, 0))
