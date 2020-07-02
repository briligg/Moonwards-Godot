extends AComponent

func _init().("RoverInteractable", true):
	pass
# Called when the node enters the scene tree for the first time.
func _ready():
	$Interactable.connect("interacted_by", self, "interacted_by")
	$Interactable.display_info = "Control the rover"

func interacted_by(interactee) -> void:
	interactee.disable()
	entity.enable()

func disable():
	pass
