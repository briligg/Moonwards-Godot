extends Spatial

var rovers : Array = [] #RigidBodies are what the rovers are.
var rover_interactable : Spatial
var sign_visible : bool = false

#Show the drive rover sign if true, Hide if false.
func _animate_sign(now_ridable : bool) -> void :
	if now_ridable :
		sign_visible = true
		$Interactable/Anim.play("show")
	else :
		sign_visible = false
		$Interactable/Anim.play("hide")

#Listen for when the rover becomes rideable.
#I would prefer this feature to be implemented via a signal connection 
#but was told not to do that
func _process(_delta : float) -> void :
	if rover_interactable.is_ridable :
		if not sign_visible :
			_animate_sign(true)
	else :
		if sign_visible :
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
			rovers.append(body)
			rover_interactable = body.get_node("RoverRideInteractable")
			
			set_process(true)
			
			if rover_interactable.is_ridable && not sign_visible :
				_animate_sign(true)

func _on_body_exited(body):
	if rovers.has(body) :
		rovers.remove(rovers.find(body))
		if rovers.empty() :
			set_process(false)
			rover_interactable = null
			if sign_visible :
				_animate_sign(false)
		
		else :
			rover_interactable = rovers[0].get_node("RoverRideInteractable")

func interacted_by(interactor):
	# A bit hacky now
	var interactable = rover_interactable.get_node("Interactable")
	interactor.get_component("Interactor").player_requested_interact(interactable)
