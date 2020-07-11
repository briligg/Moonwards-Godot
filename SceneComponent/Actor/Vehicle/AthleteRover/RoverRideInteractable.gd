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
	if !self.is_active and e != self.entity:
		call_deferred("take_control", e)
	elif self.is_active:
		call_deferred("return_control")

func take_control(e):
	interactable.display_info = "Dismount the rover"
	self.interactee = e
	self.interactee.disable()
	self.entity.enable()

	is_active = true
		
func return_control() -> void:
	interactable.display_info = "Take control of the rover"
	self.entity.disable()
	self.is_active = false
	self.interactee.enable()

func disable():
	pass
