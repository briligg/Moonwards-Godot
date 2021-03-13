extends AComponent
class_name ControllableBodyComponent


#Determines if the player can interact directly with the body.
export(bool) var direct_interaction_capable : bool = true

#Emitted when someone has lost control of me. Either from interaction or disconnect
signal control_lost()
const CONTROL_LOST = "control_lost"

var original_peer_id : int = -1
var controller_peer_id : int = -1

#Disallows other players taking control when I am being used.
var is_being_controlled : bool = false

#The entity that is controlling me.
var controlling_entity : AEntity = null

#Necessary for components.
func _init().("ControllableBodyRelay", true) -> void :
	pass

func _ready() -> void :
	#Remember what the original peer id was.
	original_peer_id = entity.owner_peer_id
	controller_peer_id = entity.owner_peer_id
	
	#Disable collisions if you are not suppose to interact directly with the component.
	if not direct_interaction_capable :
		$Interactable.set_active(false)
	
	$Interactable.connect("interacted_by", self, "_been_interacted")

func _been_interacted(interactor : Node) -> void :
	#Return control to human player.
	if  interactor.owner_peer_id == self.controller_peer_id :
		#Disable my entity and get interactor ready.
		entity.disable()
		controlling_entity.enable()

		#Reset myself.
		entity.get_component("Interactor").disable()
		entity.get_component("HumanoidInput").disable()
		entity.owner_peer_id = original_peer_id
		controller_peer_id = original_peer_id
		is_being_controlled = false

		#Hand control back to the original actor.
		entity.get_component("Camera").camera.current = false
		controlling_entity.get_component("Camera").camera.current = true
		controlling_entity.get_component("Interactor").grab_focus()
		
		#Let visibility manager know we switched context.
		VisibilityManager.reverse_context()
		
		emit_signal(CONTROL_LOST)
		var net : NetworkSignals = Signals.Network
		net.disconnect(net.CLIENT_DISCONNECTED, self, "_client_disconnected")
		return
	
	#Do nothing when someone else is already controlling me.
	#Also do nothing if the interacting body is a spacesuit lol. Temp solution until Interactors have their own layering system.
	if is_being_controlled  :
		return
	
	#Give control to the new interactor..
	if interactor.has_node("HumanoidInput") :
		interactor.get_node("HumanoidInput").disable()
	
	entity.owner_peer_id = interactor.owner_peer_id
	controller_peer_id = interactor.owner_peer_id
	
	interactor.disable()
	controlling_entity = interactor
	entity.get_component("Camera").camera.current = true
	entity.get_component("Interactor").grab_focus()
	entity.enable()
	is_being_controlled = true
	
	VisibilityManager.switch_context()
	
	#Handle when the player disconnects
	var net : NetworkSignals = Signals.Network
	net.connect(net.CLIENT_DISCONNECTED, self, "_client_disconnected")

func _client_disconnected(peer_id) -> void :
	#If controlling entity disconnects, return control to normal.
	if peer_id == entity.owner_peer_id :
		_been_interacted(entity)

func interact_with(aentity : AEntity) -> void :
	$Interactable.interact_with(aentity)
