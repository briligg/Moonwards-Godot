extends AComponent
class_name InteractorComponent

onready var interactor_ray : InteractorRayCast = $InteractorRayCast
onready var interactor_area : InteractorArea = $InteractorArea

#These allow us to call signals using actual variables instead of strings.
#const FOCUS_ROLLBACK : String = "focus_returned"
const INTERACTABLE_ENTERED_REACH : String = "interactable_entered_reach"
const INTERACTABLE_LEFT_REACH : String = "interactable_left_reach"
const INTERACTABLE_ENTERED_AREA_REACH : String = "interactable_entered_area_reach"
const INTERACTABLE_LEFT_AREA_REACH : String = "interactable_left_area_reach"

#signal focus_returned()
signal interactable_entered_reach(interactable)
signal interactable_left_reach(interactable)
signal interactable_entered_area_reach(interactable)
signal interactable_left_area_reach(interactable)

#Call grab_focus immediately at startup.
export var grab_focus_at_ready : bool = true

#Determines if the RayCast Interactor should be active or not.
export var disable_ray_cast : bool = false

var has_focus : bool = false

#This function is required by AComponent.
func _init().("Interactor", true) -> void :
	pass

#Check for when the player wants to interact with the closest interactable.
func _input(event : InputEvent) -> void :
	if not(has_focus) :
		return
	
	if event.is_action_pressed("interact_with_closest") :
		var interactable = interactor_ray.get_interactable()
		if interactable != null :
			player_requested_interact(interactable)

func _make_hud_display_interactable(interactable : Interactable = null) -> void :
	Signals.Hud.emit_signal(Signals.Hud.INTERACTABLE_ENTERED_REACH, interactable)

#Make Interactor have my Entity variable as it's user.
func _ready() -> void :
	interactor_ray.owning_entity = self.entity
	
	#Listen to the Ray Cast.
	if disable_ray_cast :
		interactor_ray.set_activity(false)
	else :
		interactor_ray.connect("new_interactable", self, "relay_signal", [INTERACTABLE_ENTERED_REACH])
		interactor_ray.connect("no_interactable_in_reach", self, "relay_signal", [null, INTERACTABLE_LEFT_REACH])
	
	#Listen for the Interactor Area signals if there is a collision shape child.
	var has_collision : bool
	var move_children : Array = []
	for child in get_children() :
		if child is CollisionShape || child is CollisionPolygon :
			has_collision = true
			var new_child = child #Errors can occur from appending for variables to arrays.
			move_children.append(new_child)
	
	#Move all collision nodes found in the root node to the InteractorArea.
	for child in move_children :
		remove_child(child)
		interactor_area.add_child(child)
	
	#Activate the InteractorArea or remove it from the scene tree.
	if has_collision :
		interactor_area.connect("interactable_entered_area", self, "relay_signal", [INTERACTABLE_ENTERED_AREA_REACH])
		interactor_area.connect("interactable_left_area", self, "relay_signal", [INTERACTABLE_LEFT_AREA_REACH])
	else :
		interactor_area.queue_free()
		interactor_area = null
	
	if grab_focus_at_ready && is_net_owner() :
		grab_focus()

#Return the closest interactable.
func get_interactable() -> Interactable :
	return interactor_ray.get_interactable()

#Return the Interactables that the Area is colliding with.
func get_interactables() -> Array :
	if interactor_area == null :
		return []
	return interactor_area.get_interactables()

#Become the current Interactor in use.
func grab_focus() -> void:
	has_focus = true
	
	Signals.Hud.emit_signal(Signals.Hud.NEW_INTERACTOR_GRABBED_FOCUS, self)
	
	#Display what is the closest interactable.
	interactor_ray.connect("new_interactable", self, "_make_hud_display_interactable")
	interactor_ray.connect("no_interactable_in_reach", self, "_make_hud_display_interactable")

#Another interactor has grabbed focus. Perform cleanup.
func lost_focus() -> void :
	has_focus = false
	interactor_ray.disconnect("new_interactable", self, "_make_hud_display_interactable")
	interactor_ray.disconnect("no_interactable_in_reach", self, "_make_hud_display_interactable")

#An Interactable has been chosen from InteractsMenu. Perform the appropriate logic for the Interactable.
func player_requested_interact(interactable : Interactable)->void:
	Log.trace(self, "", "Interacted with %s " %interactable)
	if interactable.is_networked():
		rpc_id(1, "request_interact", [interactor_ray.get_path(), interactable.get_path()])
		#I removed entity.owner_peer_id from the now empty array.
	else :
		interactor_ray.interact(interactable)

#Pass the interactor signals we are listening to onwards.
func relay_signal(attribute = null, signal_name = "interactable_made_impossible") -> void :
	emit_signal(signal_name, attribute)
	
mastersync func request_interact(args : Array) -> void :
	Log.warning(self, "", "Client %s requested an interaction" %entity.owner_peer_id)
	var interactable = get_node(args[1])
	Log.warning(self, "", "Interact mode: %s" %interactable.network_mode)
	match interactable.network_mode:
		interactable.NetworkMode.CLIENT_SERVER:
			execute_interact(args)
			rpc_id(get_tree().get_rpc_sender_id(), "execute_interact", args)
		interactable.NetworkMode.CLIENT_ONLY:
			rpc_id(get_tree().get_rpc_sender_id(), "execute_interact", args)
		interactable.NetworkMode.SERVER_ONLY:
			execute_interact(args)
		interactable.NetworkMode.PROPAGATED:
			rpc("execute_interact", args)

puppetsync func execute_interact(args: Array):
	Log.warning(self, "", "Client %s interacted request executed" %entity.owner_peer_id)
	var interactor = get_node(args[0])
	var interactable = get_node(args[1])
	interactor.interact(interactable)

func disable():
	#This gets called before _ready.
	if interactor_ray != null :
		interactor_ray.enabled = false
	.disable()

func enable():
	if is_net_owner():
		interactor_ray.enabled = true
	.enable()

