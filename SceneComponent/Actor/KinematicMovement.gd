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
	entity.move_and_slide(Vector3.ZERO, Vector3.UP)
	$OnGround.add_exception(entity)
	pass

func on_ground() -> bool:
	return $OnGround.is_colliding()

func _physics_process(_delta):
	reset_state()
	handle_input()
	apply_gravity()
	move_body()

func reset_state() -> void:
	horizontal_vector = Vector3.ZERO
	velocity = Vector3.ZERO
	# Reset gravity accel only if we're on the floor.
	if entity.is_on_floor():
		vertical_vector = Vector3.ZERO

func handle_input() -> void:
	if Input.is_action_pressed("jump") and on_ground():
		vertical_vector.y += 1 * jump_force
		
	if Input.is_action_pressed("move_forwards"):
		horizontal_vector.z += 1 * speed
	elif Input.is_action_pressed("move_backwards"):
		horizontal_vector.z += -1 * speed
		
	if Input.is_action_pressed("move_left"):
		horizontal_vector.x += 1 * speed
	elif Input.is_action_pressed("move_right"):
		horizontal_vector.x += -1 * speed
		
	horizontal_vector = horizontal_vector.normalized()

func apply_gravity() -> void:
	vertical_vector.y += -1 * WorldConstants.GRAVITY * WorldConstants.SCALE

		
func move_body() -> void:
	#entity.look_at(entity.look_dir, Vector3.UP)
	velocity += horizontal_vector
	velocity += vertical_vector
	velocity = entity.move_and_slide(velocity * WorldConstants.SCALE, Vector3.UP)
