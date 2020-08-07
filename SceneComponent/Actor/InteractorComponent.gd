extends AComponent

onready var interactor : Area = $Interactor

#These allow us to call signals using actual variables instead of strings.
#const FOCUS_ROLLBACK : String = "focus_returned"
const INTERACTABLE_ENTERED_REACH : String = "interactable_entered_reach"
const INTERACTABLE_LEFT_REACH : String = "interactable_left_reach"
const INTERACT_MADE_IMPOSSIBLE : String = "interact_made_impossible"
const INTERACT_MADE_POSSIBLE : String = "interact_made_possible"

#signal focus_returned()
signal interactable_entered_reach(interactable)
signal interactable_left_reach(interactable)
signal interact_made_impossible()
signal interact_made_possible(interact_info_string)

#Call grab_focus immediately at startup.
export var grab_focus_at_ready : bool = true

#This function is required by AComponent.
func _init().("Interactor", true) -> void :
	pass

#Check for when the player wants to interact with the closest interactable.
func _input(event : InputEvent) -> void :
	if event.is_action_pressed("interact_with_closest") :
		var interactable = interactor.get_closest_interactable()
		if interactable != null :
			on_interact_menu_request(interactable)

func _make_hud_display_interactable(interactable : Interactable = null) -> void :
	Signals.Hud.emit_signal(Signals.Hud.CLOSEST_INTERACTABLE_CHANGED, interactable)

#Make Interactor have my Entity variable as it's user.
func _ready() -> void :
	interactor.owning_entity = self.entity
	
	interactor.connect("interact_made_impossible", self, "emit_signal", [INTERACT_MADE_IMPOSSIBLE])
	interactor.connect("interact_made_possible", self, "relay_signal", [INTERACT_MADE_POSSIBLE])
	interactor.connect("interactable_entered_area", self, "relay_signal", [INTERACTABLE_ENTERED_REACH])
	interactor.connect("interactable_left_area", self, "relay_signal", [INTERACTABLE_LEFT_REACH])
	
	if grab_focus_at_ready :
		grab_focus()

#Return what interactables are in reach.
func get_interactables() -> Array :
	return interactor.get_potential_interacts()

#Become the current Interactor in use.
func grab_focus() -> void:
	Signals.Hud.emit_signal(Signals.Hud.NEW_INTERACTOR_GRABBED_FOCUS, self)
	
	#Display what is the closest interactable.
	interactor.connect("closest_interactable_changed", self, "_make_hud_display_interactable")

#Another interactor has grabbed focus. Perform cleanup.
func lost_focus() -> void :
	interactor.disconnect("closest_interactable_changed", self, "_make_hud_display_interactable")

#Pass the interactor signals we are listening to onwards.
func relay_signal(attribute = null, signal_name = "interactable_made_impossible") -> void :
	emit_signal(signal_name, attribute)
	
#An Interactable has been chosen from InteractsMenu. Perform the appropriate logic for the Interactable.
func on_interact_menu_request(interactable : Interactable)->void:
	Log.trace(self, "", "Interacted with %s " %interactable)
	if interactable.is_networked():
		rpc_id(1, "request_interact", [interactor.get_path(), interactable.get_path()])
		#I removed entity.owner_peer_id from the now empty array.
	else :
		interactor.interact(interactable)
		
mastersync func request_interact(args : Array) -> void :
	Log.warning(self, "", "Client %s requested an interaction" %entity.owner_peer_id)
	rpc_id(get_tree().get_rpc_sender_id(), "execute_interact", args)

puppetsync func execute_interact(args: Array):
	Log.warning(self, "", "Client %s interacted request executed" %entity.owner_peer_id)
	var _interactor = get_node(args[0])
	var _interactable = get_node(args[1])
	_interactor.interact(_interactable)

func disable():
	$Interactor.enabled = false
	.disable()

func enable():
	if is_net_owner():
		grab_focus()
		$Interactor.enabled = true
	.enable()

