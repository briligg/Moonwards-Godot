extends AComponent

onready var interactor : Area = $Interactor

#This function is required by AComponent.
func _init().("Interactor", true) -> void :
	pass

func _interactable_left(interactable_user_node : Node) -> void :
	Signals.Hud.emit_signal(Signals.Hud.INTERACTABLE_LEFT_REACH, interactable_user_node)

#Bring up the interact display
func _interact_made_possible(_string_closest_potential_interact : String):
	Signals.Hud.emit_signal(Signals.Hud.INTERACT_POSSIBLE, "to bring up interact menu")

#Hide the interact display when no interactions are available.
func _interact_made_impossible():
	Signals.Hud.emit_signal(Signals.Hud.INTERACT_BECAME_IMPOSSIBLE)

#Make Interactor have my Entity variable as it's user.
func _ready() -> void :
	interactor.owning_entity = self.entity
	
	#Interact with the interactable the player has chosen from the list.
	Signals.Hud.connect(Signals.Hud.INTERACT_OCCURED, interactor, "interact")
	
	#Listen for when interactions are possible and when they become impossible.
	interactor.connect("interacted_with", self, "on_interacted_with")
	interactor.connect("interactable_left_area", self, "_interactable_left")

func _unhandled_input(event : InputEvent) -> void :
	if event.is_action_pressed("use") :
		var potential_interacts : Array = interactor.get_potential_interacts()
		Signals.Hud.emit_signal(Signals.Hud.POTENTIAL_INTERACT_REQUESTED, potential_interacts)

func on_interacted_with(_interactor)->void:
	print("Interacted with %s " %_interactor)

func interactable_entered(interactable_node):
	Signals.Hud.emit_signal(Signals.Hud.INTERACTABLE_ENTERED_REACH, interactable_node)

func disable():
	$Interactor.enabled = false

func enable():
	$Interactor.enabled = true
