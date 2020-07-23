extends AComponent

var interactee
var interactee_cam

var is_active = false

# Hack
remotesync var controller_peer_id = -1

onready var interactable = $Interactable

func _init().("RoverRideInteractable", false):
	pass
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	interactable.connect("interacted_by", self, "interacted_by")
	interactable.display_info = "Take control of the rover"
	interactable.title = "Athlete Rover"

func interacted_by(e) -> void:
	if !self.is_active :
		call_deferred("take_control", e)
	elif self.is_active:
		call_deferred("return_control", e)

func take_control(e):
	if self.controller_peer_id != -1 :
		return
		
	interactable.display_info = "Dismount the rover"
	interactee = e
	interactee.disable()
#	self.entity.enabled = true
	entity.get_component("Camera").camera.current = true
	entity.get_component("RoverInput").enabled = true
	entity.get_component("Interactor").grab_focus()
	
	entity.owner_peer_id = get_tree().get_network_unique_id()
	rset("controller_peer_id", entity.owner_peer_id)
	
	is_active = true
#	interactable.is_available = false

func return_control(e) -> void:
	if e.owner_peer_id != self.controller_peer_id:
		return
		
	interactable.display_info = "Take control of the rover"
	entity.get_component("Camera").camera.current = false
	entity.get_component("RoverInput").enabled = false
	entity.owner_peer_id = -1
	rset("controller_peer_id", -1)
	is_active = false
#	interactable.is_available = true
	
	interactee.enable()
	interactee.get_component("Interactor").grab_focus()
	interactee.get_component("Camera").camera.current = true

func disable():
	pass
