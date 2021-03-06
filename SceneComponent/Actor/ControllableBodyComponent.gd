extends AComponent
class_name ControllableBodyComponent


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
	
	$Interactable.connect("interacted_by", self, "been_interacted")

func been_interacted(interactor : Node) -> void :
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
		return
	
	#Do nothing when someone else is already controlling me.
	if is_being_controlled :
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
