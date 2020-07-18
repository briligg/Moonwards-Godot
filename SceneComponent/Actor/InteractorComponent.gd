extends AComponent

onready var interactor : Area = $Interactor

#These allow us to call signals using actual variables instead of strings.
const INTERACTABLE_ENTERED_REACH : String = "interactable_entered_reach"
const INTERACTABLE_LEFT_REACH : String = "interactable_left_reach"

signal interactable_entered_reach(interactable)
signal interactable_left_reach(interactable)

#Call grab_focus immediately at startup.
export var grab_focus_at_ready : bool = false


#This function is required by AComponent.
func _init().("Interactor", true) -> void :
	pass

func _interactable_left(interactable_node : Node) -> void :
	.emit_signal("interactable_left_reach", interactable_node)

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
	Signals.Hud.connect(Signals.Hud.INTERACT_OCCURED, self, "on_interact_menu_request")

#Call after chosen from InteractsMenu. Networks that the interaction happened.
func on_interact_menu_request(interactable : Interactable)->void:
	Log.trace(self, "", "Interacted with %s " %interactable)
	if interactable.is_networked() and !get_tree().is_network_server():
		crpc("request_interact", [interactor.get_path(), interactable.get_path()], [])
		#I removed entity.owner_peer_id from the now empty array.
	else :
		interactor.interact(interactable)

master func request_interact(args : Array) -> void :
	Log.warning(self, "", "Client %s requested an interaction" %entity.owner_peer_id)
	crpc("execute_interact", args)

puppetsync func execute_interact(args: Array):
	Log.warning(self, "", "Client %s interacted request executed" %entity.owner_peer_id)
	var _interactor = get_node(args[0])
	var _interactable = get_node(args[1])
	_interactor.interact(_interactable)
	Signals.Hud.connect(Signals.Hud.INTERACT_OCCURED, interactor, "interact")

func grab_focus() -> void :
	Signals.Hud.emit_signal(Signals.Hud.NEW_INTERACTOR_GRABBED_FOCUS, self)
	interactor.connect("interact_made_impossible", self, "interact_made_impossible")
	interactor.connect("interact_made_possible", self, "interact_made_possible")
	interactor.connect("interactable_entered_area", self, "_interactable_entered")
	interactor.connect("interactable_left_area", self, "_interactable_left")
>>>>>>> Commit for InteractsMenu

#The focus has been given to another interactor componennt.
func lost_focus() -> void :
	interactor.disconnect("interact_made_impossible", self, "interact_made_impossible")
	interactor.disconnect("interact_made_possible", self, "interact_made_possible")
	interactor.disconnect("interactable_entered_area", self, "_interactable_entered")
	interactor.disconnect("interactable_left_area", self, "_interactable_left")

func on_interacted_with(_interactor)->void:
	print("Interacted with %s " %_interactor)

func _interactable_entered(interactable_node):
	.emit_signal("interactable_entered_reach", interactable_node)
