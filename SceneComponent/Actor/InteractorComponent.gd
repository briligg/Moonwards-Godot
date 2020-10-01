extends AComponent
class_name InteractorComponent

onready var interactor : InteractorRayCast = $InteractorRayCast

#These allow us to call signals using actual variables instead of strings.
#const FOCUS_ROLLBACK : String = "focus_returned"
const INTERACTABLE_ENTERED_REACH : String = "interactable_entered_reach"
const INTERACTABLE_LEFT_REACH : String = "interactable_left_reach"

#signal focus_returned()
signal interactable_entered_reach(interactable)
signal interactable_left_reach(interactable)

#Call grab_focus immediately at startup.
export var grab_focus_at_ready : bool = true

var has_focus : bool = false

#This function is required by AComponent.
func _init().("Interactor", true) -> void :
	pass

#Check for when the player wants to interact with the closest interactable.
func _input(event : InputEvent) -> void :
	if not(has_focus) :
		return
	
	if event.is_action_pressed("interact_with_closest") :
		var interactable = interactor.get_interactable()
		if interactable != null :
			player_requested_interact(interactable)

func _make_hud_display_interactable(interactable : Interactable = null) -> void :
	Signals.Hud.emit_signal(Signals.Hud.INTERACTABLE_ENTERED_REACH, interactable)

#Make Interactor have my Entity variable as it's user.
func _ready() -> void :
	interactor.owning_entity = self.entity
	
	interactor.connect("new_interactable", self, "relay_signal", [INTERACTABLE_ENTERED_REACH])
	interactor.connect("no_interactable_in_reach", self, "relay_signal", [null, INTERACTABLE_LEFT_REACH])
	
	if grab_focus_at_ready :
		grab_focus()

#Return what interactables are in reach.
func get_interactable() -> Interactable :
	return interactor.get_interactable()

#Become the current Interactor in use.
func grab_focus() -> void:
	has_focus = true
	
	Signals.Hud.emit_signal(Signals.Hud.NEW_INTERACTOR_GRABBED_FOCUS, self)
	
	#Display what is the closest interactable.
	interactor.connect("new_interactable", self, "_make_hud_display_interactable")
	interactor.connect("no_interactable_in_reach", self, "_make_hud_display_interactable")

#Another interactor has grabbed focus. Perform cleanup.
func lost_focus() -> void :
	has_focus = false
	interactor.disconnect("new_interactable", self, "_make_hud_display_interactable")
	interactor.disconnect("no_interactable_in_reach", self, "_make_hud_display_interactable")

#An Interactable has been chosen from InteractsMenu. Perform the appropriate logic for the Interactable.
func player_requested_interact(interactable : Interactable)->void:
	Log.trace(self, "", "Interacted with %s " %interactable)
	if interactable.is_networked():
		rpc_id(1, "request_interact", [interactor.get_path(), interactable.get_path()])
		#I removed entity.owner_peer_id from the now empty array.
	else :
		interactor.interact(interactable)

#Pass the interactor signals we are listening to onwards.
func relay_signal(attribute = null, signal_name = "interactable_made_impossible") -> void :
	emit_signal(signal_name, attribute)
	
mastersync func request_interact(args : Array) -> void :
	Log.warning(self, "", "Client %s requested an interaction" %entity.owner_peer_id)
	rpc_id(get_tree().get_rpc_sender_id(), "execute_interact", args)

puppetsync func execute_interact(args: Array):
	Log.warning(self, "", "Client %s interacted request executed" %entity.owner_peer_id)
	var _interactor = get_node(args[0])
	var _interactable = get_node(args[1])
	_interactor.interact(_interactable)

func disable():
	interactor.enabled = false
	.disable()

func enable():
	if is_net_owner():
		interactor.enabled = true
	.enable()

