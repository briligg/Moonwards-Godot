extends Spatial

var rover
var rover_interactable : Spatial
var sign_visible : bool = false
var is_rover_available = false

#Show the drive rover sign if true, Hide if false.
func _animate_sign(now_ridable : bool) -> void :
	if now_ridable :
		$Interactable/Anim.play("show")
	else :
		$Interactable/Anim.play("hide")

#Listen for when the rover becomes rideable.
#I would prefer this feature to be implemented via a signal connection 
#but was told not to do that
func _process(_delta : float) -> void :
	if rover_interactable.is_ridable :
		if not sign_visible :
			sign_visible = true
			_animate_sign(true)
	elif sign_visible :
		sign_visible = false
		_animate_sign(false)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_process(false)
	
	$RoverDetection.connect("body_entered", self, "_on_body_entered")
	$RoverDetection.connect("body_exited", self, "_on_body_exited")
	$Interactable.connect("interacted_by", self, "interacted_by")

func _on_body_entered(body: Node):
	if body.is_in_group("athlete_rover"):
		if body.get_node("RoverRideInteractable") != null:
			rover = body
			rover_interactable = rover.get_node("RoverRideInteractable")
			is_rover_available = true
			
			#Display the mesh if the Rover is ready to be driven.
			if rover_interactable.is_ridable :
				set_process(true)
				_animate_sign(true)

func _on_body_exited(body):
	if body == rover:
		if rover != null :
			set_process(false)
		rover_interactable = null
		body = null
		is_rover_available = false

func interacted_by(interactor):
	# A bit hacky now
	var interactable = rover.get_node("RoverRideInteractable").get_node("Interactable")
	interactor.get_component("Interactor").player_requested_interact(interactable)
