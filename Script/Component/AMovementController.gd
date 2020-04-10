extends AComponent
class_name AMovementController
# Serves as the base controller class, will contain necessary data to handle
# movement

# Actor mass in KGs
export(float) var mass = 70.0

# Velocity of the actor
var velocity: Vector3 = Vector3()

# The direction in which we're headed
var heading: Vector3 = Vector3()

# The angle at which we're looking relative to our transform
var look_dir: Vector3 = Vector3()

# Init parent with component name
func _init().("AMovementController") -> void:
	pass

func is_grounded() -> bool:
	return $OnGround.is_colliding()
