extends AComponent
class_name AMovementController
# Serves as the base controller class, will contain necessary data to handle
# movement

# Actor mass in KGs
export(float) var mass = 70.0

# Velocity of the actor
export(Vector3) var velocity = Vector3()

# The angle at which we're looking relative to our transform
export(Vector3) var look_dir = Vector3()

# Init parent with component name
func _init().("AMovementController"):
	pass
