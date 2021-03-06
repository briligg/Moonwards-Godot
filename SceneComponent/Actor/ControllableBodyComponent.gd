extends AComponent
class_name ControllableBodyComponent


var in_use : bool = false

var original_peer_id : int = -1
var controller_peer_id : int = -1

#Disallows other players taking control when I am being used.
var is_being_controlled : bool = false

#Necessary for components.
func _init().("ControllableBodyRelay", true) -> void :
	pass

func _ready() -> void :
	#Remember what the original peer id was.
	original_peer_id = entity.owner_peer_id
	controller_peer_id = entity.owner_peer_id
	
	$Interactable.connect("interacted_by", self, "been_interacted")

func been_interacted(interactor : Node) -> void :
	if in_use :
		return
	
	#Return control to human player.
	if interactor.owner_peer_id == self.controller_peer_id :
		interactor.get_component("Camera").camera.current = true
		interactor.get_component("Interactor").grab_focus()
		entity.owner_peer_id = original_peer_id
		controller_peer_id = original_peer_id
		is_being_controlled = false
		return
	
	#Do nothing if someone is controlling me and they try to take control.
	if is_being_controlled :
		return
	
	#Give control to the new interactor..
	if interactor.has_node("HumanoidInput") :
		interactor.get_node("HumanoidInput").disable()
	
	entity.owner_peer_id = interactor.owner_peer_id
	controller_peer_id = interactor.owner_peer_id
	
	entity.get_component("Camera").camera.current = true
	entity.get_component("Interactor").grab_focus()
	entity.enable()
	is_being_controlled = true
