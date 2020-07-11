extends AComponent

var interactee
var interactee_cam

var is_active = false

onready var interactable = $Interactable

func _init().("RoverRideInteractable", true):
	pass
# Called when the node enters the scene tree for the first time.
func _ready():
	interactable.connect("interacted_by", self, "interacted_by")
	interactable.display_info = "Take control of the rover"
	interactable.title = "Athlete Rover"

func interacted_by(e) -> void:
	if !self.is_active:
		take_control(e)
	elif self.is_active:
		return_control()

func take_control(e):
	interactable.display_info = "Dismount the rover"
	self.interactee = e
	self.interactee_cam = interactee.get_component("Camera").camera
	self.interactee.disable()
	self.entity.enable()
	var cam = entity.get_component("Camera")
	if cam:
		cam.camera.current = true
	is_active = true
		
func return_control() -> void:
	interactable.display_info = "Take control of the rover"
	self.interactee.enable()
	self.interactee_cam.current = true
	self.entity.disable()
	self.is_active = false

func disable():
	pass
