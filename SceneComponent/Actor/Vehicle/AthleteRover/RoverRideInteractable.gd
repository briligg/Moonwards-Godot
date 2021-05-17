extends AComponent


onready var original_pos : Vector3 = entity.transform.origin

var interactee
var interactee_cam

puppetsync var is_ridable = true
puppetsync var controller_peer_id = -1

onready var interactable = $Interactable
onready var timer : Timer = $ResetRoverTimer

func _init().("RoverRideInteractable", false):
	pass
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	interactable.connect("interacted_by", self, "interacted_by")
	interactable.display_info = "Take control of the rover"
	interactable.title = "Athlete Rover"
	Signals.Network.connect(NetworkSignals.CLIENT_DISCONNECTED, self, "_client_disconnected")
	
	timer.connect("timeout", self, "_reset_rover")

# This only runs on the server.
func interacted_by(e) -> void:
	var path = e.get_path()
	
	if self.is_ridable :
		#Rovers and other vehicles are not allowed to take control of me.
		if e is VehicleEntity :
			return
		
		#Take control.
		if self.controller_peer_id == -1:
			rpc_id(get_tree().get_rpc_sender_id(), "deferred_take_control", path)
			rpc("update_control_state", get_tree().get_rpc_sender_id(), false)
			
			#Stop the timer until the player has taken control of the rover again.
			timer.stop()

	#Return control
	elif !self.is_ridable:
		if get_tree().get_rpc_sender_id() == self.controller_peer_id:
			rpc_id(get_tree().get_rpc_sender_id(), "deferred_return_control", path)
			rpc("update_control_state", -1, true)
			
			#Start the timer so that the Rover will spawn at the starting location if it timeouts.
			timer.start(1800)
			
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
	
#	update_control_state(Network.network_instance.peer_id, false)
	
func return_control(_e) -> void:
	interactable.display_info = "Take control of the rover"
	entity.get_component("Camera").camera.current = false
	entity.get_component("RoverInput").enabled = false
	
#	update_control_state(-1, true)
	
	VisibilityManager.reverse_context()
	interactee.enable()
	interactee.get_component("Interactor").grab_focus()
	interactee.get_component("Camera").camera.current = true

puppetsync func update_control_state(peer_id, return_control = false):
	# owner_peer_id in use to validate driving requests
	entity.owner_peer_id = peer_id
	self.controller_peer_id = peer_id

	is_ridable = return_control
	interactable.is_available = return_control

func update_network():
	rset("controller_peer_id", controller_peer_id)
	rset("is_ridable", is_ridable)

func disable():
	pass

func sync_for_new_player(peer_id):
	rset_id(peer_id, "is_ridable", is_ridable)
	rset_id(peer_id, "controller_peer_id", controller_peer_id)
	
func _client_disconnected(peer_id):
	if peer_id == controller_peer_id:
		update_control_state(-1, true)
		update_network()
		timer.stop()

#Called by signal when the timer has expired.
func _reset_rover() -> void :
	entity.transform.origin = original_pos
	timer.stop()
