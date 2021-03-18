extends AComponent
class_name ControllableBodyComponent


#Determines if the player can interact directly with the body.
export(bool) var direct_interaction_capable : bool = true

#Emitted when someone has lost control of me. Either from interaction or disconnect
signal control_lost()
const CONTROL_LOST = "control_lost"

#Emitted when someone takes control of me.
signal control_taken(aentity_taking_control)
const CONTROL_TAKEN = "control_taken"

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
	$Interactable.connect("sync_for_new_player", self, "sync_for_new_player")

func _been_interacted(interactor : Node) -> void :
	#Return control to human player.
	if  interactor.owner_peer_id == self.controller_peer_id :
		#Disable my entity and get interactor ready.
		rpc("_sync_return_control")

		#Hand control back to the original actor.
		entity.get_component("Camera").camera.current = false
		controlling_entity.get_component("Camera").camera.current = true
		controlling_entity.get_component("Interactor").grab_focus()
		
		#Let visibility manager know we switched context.
		VisibilityManager.reverse_context()
		
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
	
	entity.get_component("Camera").camera.current = true
	entity.get_component("Interactor").grab_focus()
	crpc("_sync_take_control", interactor.get_path())
	
	VisibilityManager.switch_context()
	
	#Handle when the player disconnects
	var net : NetworkSignals = Signals.Network
	net.connect(net.CLIENT_DISCONNECTED, self, "_client_disconnected")

sync func _sync_return_control() -> void :
	entity.disable()
	controlling_entity.enable()
	controlling_entity.show()
	
	entity.get_component("NametagComponent").hide()
	entity.get_component("Interactor").disable()
	entity.get_component("HumanoidInput").disable()
	entity.owner_peer_id = original_peer_id
	controller_peer_id = original_peer_id
	is_being_controlled = false
	
	emit_signal(CONTROL_LOST)

#Called when someone else takes control of me.
sync func _sync_take_control(interactor_path : NodePath) -> void :
	var interactor = get_tree().get_root().get_node(interactor_path)
	#Give control to the new interactor..
	entity.owner_peer_id = interactor.owner_peer_id
	controller_peer_id = interactor.owner_peer_id
	
	interactor.disable()
	interactor.hide()
	controlling_entity = interactor
	entity.get_component("NametagComponent").show()
	entity.get_component("NametagComponent").set_name(interactor.entity_name)
	entity.enable()
	is_being_controlled = true
	
	emit_signal(CONTROL_TAKEN, interactor)

func _client_disconnected(peer_id) -> void :
	#If controlling entity disconnects, return control to normal.
	if peer_id == entity.owner_peer_id :
		_been_interacted(entity)

func interact_with(aentity : AEntity) -> void :
	$Interactable.interact_with(aentity)

func sync_for_new_player(peer_id) -> void :
	if not controlling_entity == null :
		rpc_id(peer_id, "sync_to_master", controlling_entity.get_path())
	else :
		rpc_id(peer_id, "sync_to_master", null)

puppet func sync_to_master(entity_path : NodePath) -> void :
	if not entity_path == null :
		controlling_entity = get_tree().get_root().get_node(entity_path)
		_sync_take_control(entity_path)
		is_being_controlled = true
