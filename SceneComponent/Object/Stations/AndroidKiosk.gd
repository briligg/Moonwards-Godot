extends Spatial



func _interaction(interactor : AEntity) -> void :
	var comp : InteractorComponent =interactor.get_component("Interactor")
	var android : AEntity = get_node(android_to_control)
	comp.player_requested_interact(android.get_node("ControllableBodyComponent/Interactable"))

func _ready() -> void :
	$Interactable.connect("interacted_by", self, "_interaction")
