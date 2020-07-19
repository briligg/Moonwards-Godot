extends AComponent

onready var interactor : Area = $Interactor

#These allow us to call signals using actual variables instead of strings.
const INTERACTABLE_ENTERED_REACH : String = "interactable_entered_reach"
const INTERACTABLE_LEFT_REACH : String = "interactable_left_reach"
const INTERACT_MADE_IMPOSSIBLE : String = "interact_made_impossible"
const INTERACT_MADE_POSSIBLE : String = "interact_made_possible"

signal interactable_entered_reach(interactable)
signal interactable_left_reach(interactable)
signal interact_made_impossible()
signal interact_made_possible(interact_info_string)

#Call grab_focus immediately at startup.
export var grab_focus_at_ready : bool = false


#This function is required by AComponent.
func _init().("Interactor", true) -> void :
	pass

#Make Interactor have my Entity variable as it's user.
func _ready() -> void :
	interactor.owning_entity = self.entity
	
	#Interact with the interactable the player has chosen from the list.
	Signals.Hud.connect(Signals.Hud.INTERACT_OCCURED, self, "on_interact_menu_request")
	
	if grab_focus_at_ready :
		call_deferred("grab_focus")

master func request_interact(args : Array) -> void :
	Log.warning(self, "", "Client %s requested an interaction" %entity.owner_peer_id)
	crpc("execute_interact", args)

#A different player interacted with a networked Interactable.
puppetsync func execute_interact(args: Array):
	Log.warning(self, "", "Client %s interacted request executed" %entity.owner_peer_id)
	var _interactor = get_node(args[0])
	var _interactable = get_node(args[1])
	_interactor.interact(_interactable)
	Signals.Hud.connect(Signals.Hud.INTERACT_OCCURED, interactor, "interact")

#Become the current Interactor in use.
func grab_focus() -> void :
	Signals.Hud.emit_signal(Signals.Hud.NEW_INTERACTOR_GRABBED_FOCUS, self)
	interactor.connect("interact_made_impossible", self, "emit_signal", [INTERACT_MADE_IMPOSSIBLE])
	interactor.connect("interact_made_possible", self, "relay_signal", [INTERACT_MADE_POSSIBLE])
	interactor.connect("interactable_entered_area", self, "relay_signal", [INTERACTABLE_ENTERED_REACH])
	interactor.connect("interactable_left_area", self, "relay_signal", [INTERACTABLE_LEFT_REACH])

#The focus has been given to another interactor componennt.
func lost_focus() -> void :
	interactor.disconnect("interact_made_impossible", self, "emit_signal")
	interactor.disconnect("interact_made_possible", self, "relay_signal")
	interactor.disconnect("interactable_entered_area", self, "relay_signal")
	interactor.disconnect("interactable_left_area", self, "relay_signal")

#An Interactable has been chosen from InteractsMenu. Perform the appropriate logic for the Interactable.
func on_interact_menu_request(interactable : Interactable)->void:
	Log.trace(self, "", "Interacted with %s " %interactable)
	if interactable.is_networked() :
		crpc("request_interact", [interactor.get_path(), interactable.get_path()], [entity.owner_peer_id])
	else :
		interactor.interact(interactable)

#Pass the interactor signals we are listening to onwards.
func relay_signal(attribute = null, signal_name = "interactable_made_impossible") -> void :
	.emit_signal(signal_name, attribute)

#Someone interacted with a networked Interactable.
master func request_interact(args : Array) -> void :
	Log.warning(self, "", "Client %s requested an interaction" %entity.owner_peer_id)
	crpc("execute_interact", args)
