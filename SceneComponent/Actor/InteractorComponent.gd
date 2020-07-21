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

func interactable_entered(interactable_node):
	Signals.Hud.emit_signal(Signals.Hud.INTERACTABLE_ENTERED_REACH, interactable_node)

func disable():
	$Interactor.enabled = false
	.disable()

func enable():
	if is_net_owner():
		$Interactor.enabled = true
	.enable()
