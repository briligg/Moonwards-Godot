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

func _on_body_exited(body):
	if body == rover:
		body = null
		is_rover_available = false

func interacted_by(interactor):
	var interact = rover.get_node("RoverRideInteractable")
	interact.interacted_by(interactor)
