extends AComponent

var interactee
var interactee_cam

var is_active = false

func _init().("RoverRideInteractable", true):
	pass
# Called when the node enters the scene tree for the first time.
func _ready():
	$Interactable.owning_entity = self.entity
	$Interactable.display_info = "Dock to rover"

func disable():
	pass
