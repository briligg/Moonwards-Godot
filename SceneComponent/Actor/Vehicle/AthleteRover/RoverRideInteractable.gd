extends AComponent

var interactee
var interactee_cam

# Hack
puppetsync var is_ridable = true
puppetsync var controller_peer_id = -1

onready var interactable = $Interactable

func _init().("RoverRideInteractable", false):
	pass
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	interactable.connect("interacted_by", self, "interacted_by")
	interactable.display_info = "Take control of the rover"
	interactable.title = "Athlete Rover"

# This only runs on the server.
func interacted_by(e) -> void:
	var path = e.get_path()
	
	if self.is_ridable :
		if self.controller_peer_id == -1:
			rpc_id(get_tree().get_rpc_sender_id(), "deferred_take_control", path)
			update_control_state(Network.network_instance.peer_id, false)
	elif !self.is_ridable:
		if get_tree().get_rpc_sender_id() == self.controller_peer_id:
			rpc_id(get_tree().get_rpc_sender_id(), "deferred_return_control", path)
			update_control_state(-1, true)
	update_network()

puppetsync func deferred_take_control(path):
	call_deferred("take_control", get_node(path))

puppetsync func deferred_return_control(path):
	call_deferred("return_control", get_node(path))

func take_control(e):
	interactable.display_info = "Dismount the rover"
	interactee = e
	interactee.disable()
	VisibilityManager.switch_context()
	
	# Entity being the rover
	entity.get_component("Camera").camera.current = true
	entity.get_component("RoverInput").enabled = true
	entity.get_component("Interactor").grab_focus()
	
	update_control_state(Network.network_instance.peer_id, false)
	
#	entity.owner_peer_id = Network.network_instance.peer_id
#	self.controller_peer_id = Network.network_instance.peer_id
#	is_ridable = true
#	interactable.is_available = false
	
func return_control(e) -> void:
	interactable.display_info = "Take control of the rover"
	entity.get_component("Camera").camera.current = false
	entity.get_component("RoverInput").enabled = false
	
	update_control_state(-1, true)
	
	VisibilityManager.reverse_context()
	interactee.enable()
	interactee.get_component("Interactor").grab_focus()
	interactee.get_component("Camera").camera.current = true

func update_control_state(peer_id, return_control = false):
	entity.owner_peer_id = peer_id
	self.controller_peer_id = peer_id
	is_ridable = return_control
	interactable.is_available = return_control

func update_network():
	rset("controller_peer_id", controller_peer_id)
	rset("is_ridable", is_ridable)

func disable():
	pass

puppet func sync_for_new_player(peer_id):
	rset_id(peer_id, "is_ridable", is_ridable)
	rset_id(peer_id, "controller_peer_id", controller_peer_id)
	
