extends AComponent
class_name AMovementController
# Serves as the base controller class, will contain necessary data to handle
# movement

# Actor mass in KGs
export(float) var mass = 70.0

# Init parent with component name
func _init().("AMovementController"):
	pass
