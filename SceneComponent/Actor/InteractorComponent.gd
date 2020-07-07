extends AComponent

onready var interactor : Area = $Interactor

#This function is required by AComponent.
func _init().("PlayerInteractor", true) -> void :
	pass

#Make Interactor have my Entity variable as it's user.
func _ready() -> void :
	interactor.owning_entity = self.entity
	
	#Interact with the interactable the player has chosen from the list.
	Signals.Hud.connect(Signals.Hud.INTERACT_OCCURED, interactor, "interact")
	
	#Listen for when interactions are possible and when they become impossible.
	interactor.connect("interacted_with", self, "on_interacted_with")

func _unhandled_input(event : InputEvent) -> void :
	if event.is_action_pressed("use") :
		var potential_interacts : Array = interactor.get_potential_interacts()
		if potential_interacts.empty() == false :
			Signals.Hud.emit_signal(Signals.Hud.POTENTIAL_INTERACT_REQUESTED, potential_interacts)

func on_interacted_with(_interactor)->void:
	print("Interacted with %s " %_interactor)

#Bring up the interact display
func _interact_made_possible(_string_closest_potential_interact : String):
	Signals.Hud.emit_signal(Signals.Hud.INTERACT_POSSIBLE, "Press use to bring up interact menu")

#Hide the interact display when no interactions are available.
func _interact_made_impossible():
	Signals.Hud.emit_signal(Signals.Hud.INTERACT_BECAME_IMPOSSIBLE)
