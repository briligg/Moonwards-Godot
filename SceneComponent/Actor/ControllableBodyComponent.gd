extends AComponent
class_name ControllableBodyComponent


#Determines if the player can interact directly with the body.
export(bool) var direct_interact_at_start : bool = false
export(bool) var direct_interaction_capable : bool = true
export(bool) var hide_interactor_entity : bool = true

export(String) var interactable_title = "interactable_title"
export(String) var interactable_info = "interactable_info"

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
func _init().("ControllableBodyComponent", true) -> void :
	pass

func _ready() -> void :
	#Remember what the original peer id was.
	original_peer_id = entity.owner_peer_id
	controller_peer_id = entity.owner_peer_id
	
	#Disable collisions if you are not suppose to interact directly with the component.
	if not direct_interaction_capable :
		$Interactable.set_active(false)
	elif direct_interact_at_start && direct_interaction_capable :
		$Interactable.set_active(true)
	else :
		$Interactable.set_active(false)
	
	$Interactable.connect("interacted_by", self, "_been_interacted")
	$Interactable.connect("sync_for_new_player", self, "sync_for_new_player")
	
	#Set the Interactable's parameters.
	$Interactable.set_display_info(interactable_info)
	$Interactable.set_title(interactable_title)
	
	call_deferred("_ready_deferred")

#Move any collision shape node from the root node to the Interactable
func _ready_deferred() -> void :
	for child in get_children() :
		if child is CollisionShape :
			Helpers.reparent(child, $Interactable)

#Only runs on the server.
func _been_interacted(interactor : Node) -> void :
	#Get who sent this interaction.
	var sender_id : int = get_tree().get_rpc_sender_id()
	
	#Return control to human player.
	if  interactor.owner_peer_id == self.controller_peer_id :
		rpc_id(sender_id, "_sync_return_control_acting_player")
		#Disable my entity and get interactor ready.
		rpc("_sync_return_control")
		
		var net : NetworkSignals = Signals.Network
		net.disconnect(net.CLIENT_DISCONNECTED, self, "_client_disconnected")
		return
	
	#Do nothing when someone else is already controlling me.
	#Also do nothing if the other interactor is a ControllableBodyComponent
	if is_being_controlled  || interactor.has_node("ControllableBodyComponent") :
		return
	
	#Will this always go according to order?
	rpc_id(sender_id, "_sync_take_control_acting_player", interactor.get_path())
	rpc("_sync_take_control", interactor.get_path())
	
	VisibilityManager.switch_context()
	
	#Handle when the player disconnects
	var net : NetworkSignals = Signals.Network
	net.connect(net.CLIENT_DISCONNECTED, self, "_client_disconnected")

#Called for everyone when someone returns control.
puppetsync func _sync_return_control() -> void :
	entity.disable()
	if not controlling_entity == null :
		controlling_entity.enable()
		controlling_entity.show()
	
	entity.get_component("NametagComponent").hide()
	entity.get_component("Interactor").disable()
	entity.get_component("HumanoidInput").disable()
	entity.owner_peer_id = original_peer_id
	controller_peer_id = original_peer_id
	is_being_controlled = false
	
	controlling_entity = null
	
	emit_signal(CONTROL_LOST)

#This is called when I am being controlled by the local player.
puppet func _sync_return_control_acting_player() -> void :
	#Stop my current camera and hand it back to player's main AEntity.
	entity.get_component("Camera").camera.current =false
	
	#Check that no errors occured that left controlling_entity null
	if controlling_entity == null :
		Log.error(self, "_sync_return_control_acting_player", "Spacesuit attempted to return control with a null controlling entity %s" % get_path())
		return
		
	#Give the controlling player back it's control.
	controlling_entity.get_component("Camera").camera.current = true
	controlling_entity.get_component("Interactor").grab_focus()

	#Let visibility manager know we switched context.
	VisibilityManager.reverse_context()
	
	#Give control to the new interactor..
	if controlling_entity.has_node("HumanoidInput") :
		controlling_entity.get_node("HumanoidInput").disable()
	
	if direct_interaction_capable :
		$Interactable.set_active(false)

#Called for everyone when someone takes control of me.
puppetsync  func _sync_take_control(interactor_path : NodePath) -> void :
	#Get AEntity taking control.
	if not get_tree().get_root().has_node(interactor_path) :
		Log.error(self, "_sync_take_control", "Interacting AEntity not found for %s" % get_path())
		return
	var interactor : ActorEntity = get_tree().get_root().get_node(interactor_path)
	
	#Give control to the new interactor..
	entity.owner_peer_id = interactor.owner_peer_id
	controller_peer_id = interactor.owner_peer_id
	
	interactor.disable()
	if hide_interactor_entity :
		interactor.hide()
	controlling_entity = interactor
	entity.get_component("NametagComponent").show()
	entity.get_component("NametagComponent").set_name(interactor.entity_name)
	entity.enable()
	is_being_controlled = true
	
	#Make the entity have a global transformation so no bugs happen with parent rotation.
	var trans : Basis = interactor.model.global_transform.basis
	trans.x.x = 1
	trans.y.y  = 1
	trans.z.z = 1
	interactor.model.global_transform.basis = trans
	
	emit_signal(CONTROL_TAKEN, interactor)

#Called for the player actually performing the action.

puppet func _sync_take_control_acting_player(interactor_path : NodePath) -> void :
	#Get AEntity taking control.
	if not get_tree().get_root().has_node(interactor_path) :
		Log.error(self, "_sync_take_control", "Interacting AEntity not found for %s" % get_path())
		return
	var interactor : AEntity = get_tree().get_root().get_node(interactor_path)
	
	entity.get_component("Camera").camera.current = true
	interactor.get_component("Camera").camera.current = false
	entity.get_component("Interactor").grab_focus()

	#Let visibility manager know we switched context.
	VisibilityManager.switch_context()
	
	#Give control to the new interactor..
	if interactor.has_node("HumanoidInput") :
		interactor.get_node("HumanoidInput").disable()
	
	#Let the player exit the controllable body component.
	if direct_interaction_capable :
		$Interactable.set_active(true)

func _client_disconnected(peer_id) -> void :
	#If controlling entity disconnects, return control to normal.
	if peer_id == entity.owner_peer_id :
		rpc("_sync_return_control")

#Handled only on the server.
func sync_for_new_player(peer_id) -> void :
	if not controlling_entity == null :
		rpc_id(peer_id, "sync_to_master", controlling_entity.get_path())
	else :
		rpc_id(peer_id, "sync_to_master")

puppet func sync_to_master(entity_path : NodePath = self.get_path()) -> void :
	#Have an entity take control if necessary.
	if not entity_path == self.get_path() :
		#Check that the path is valid.
		if not get_tree().get_root().has_node(entity_path) :
			Log.error(self, "sync_to_master", "Passed entity_path %s does not have an entity" % str(entity_path))
			return
			
		call_deferred("_sync_take_control", entity_path)
