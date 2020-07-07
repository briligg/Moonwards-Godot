extends AComponent

#This function is required by AComponent.
func _init().("RoverDockInteractor", true) -> void :
	pass

#Make Interactor have my Entity variable as it's user.
func _ready() -> void :
	$Interactor.owning_entity = self.entity
	
	#Listen for when interactions are possible and when they become impossible.
	$Interactor.connect("interact_made_possible", self, "on_interact_possible")
	$Interactor.connect("interact_made_impossible", self, "on_interact_impossible")
	$Interactor.connect("interacted_with", self, "on_interacted_with")

func _unhandled_input(event : InputEvent) -> void :
	if event.is_action_pressed("use") :
		$Interactor.interact()

func on_interact_impossible() -> void :
	Signals.Hud.emit_signal(Signals.Hud.INTERACT_BECAME_IMPOSSIBLE)

func on_interact_possible(interact_info : String) -> void :
	Signals.Hud.emit_signal(Signals.Hud.INTERACT_POSSIBLE, interact_info)

func on_interacted_with(interactor)->void:
	var parent = interactor.get_parent()
	parent.remove_child(interactor)
	entity.add_child(interactor)
	interactor.transform = self.transform
