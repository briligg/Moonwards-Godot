extends Spatial

var rover
var is_rover_available = false

func _animate_rover(now_ridable : bool) -> void :
	if now_ridable :
		$Interactable/Anim.play("show")
	else :
		$Interactable/Anim.play("hide")

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
			
			var rover_interactable = rover.get_node("RoverRideInteractable")
			rover_interactable.connect(rover_interactable.RIDABLE_CHANGED, self, "_animate_rover")
			
			#Display the mesh if the Rover is ready to be driven.
			if rover_interactable.is_ridable :
				_animate_rover(true)

func _on_body_exited(body):
	if body == rover:
		if rover != null :
			var rover_interactable = rover.get_node("RoverRideInteractable")
			rover_interactable.disconnect(rover_interactable.RIDABLE_CHANGED, self, "_animate_rover")
		body = null
		is_rover_available = false

func interacted_by(interactor):
	# A bit hacky now
	var interactable = rover.get_node("RoverRideInteractable").get_node("Interactable")
	interactor.get_component("Interactor").player_requested_interact(interactable)
