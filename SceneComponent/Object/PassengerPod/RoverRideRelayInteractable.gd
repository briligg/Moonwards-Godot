extends Spatial

var rover
var is_rover_available = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	$RoverDetection.connect("body_entered", self, "_on_body_entered")
	$RoverDetection.connect("body_exited", self, "_on_body_exited")
	$Interactable.connect("interacted_by", self, "interacted_by")

func _on_body_entered(body: Node):
	if body.is_in_group("athlete_rover"):
		if body.get_node("RoverRideInteractable") != null:
			rover = body
			is_rover_available = true
			
			rover.connect(rover.RIDABLE_CHANGED, self, "_animate_rover")

func _on_body_exited(body):
	if body == rover:
		if rover != null :
			rover.disconnect(rover.RIDABLE_CHANGED, self, "_animate_rover")
		body = null
		is_rover_available = false

func interacted_by(interactor):
	# A bit hacky now
	var interactable = rover.get_node("RoverRideInteractable").get_node("Interactable")
	interactor.get_component("Interactor").player_requested_interact(interactable)
