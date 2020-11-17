extends AComponent
class_name InteractorComponent

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

onready var interactor_ray : RayCast = $InteractorRayCast
onready var interactor_area : InteractorArea = $InteractorArea

#Call grab_focus immediately at startup.
export var grab_focus_at_ready : bool = true

#Determines if the RayCast Interactor should be active or not.
export var disable_ray_cast : bool = false

var _latest_mouse_motion: InputEventMouseMotion
var _latest_mouse_click: InputEventMouseButton

#When chatting, do not interact with objects.
var can_interact : bool = true

var has_focus : bool = false

#This function is required by AComponent.
func _init().("Interactor", true) -> void :
	pass

#Make Interactor have my Entity variable as it's user.
func _ready() -> void :
	#Listen for when chat starts and stops to know when to avoid interacting.
	Signals.Hud.connect(Signals.Hud.CHAT_TYPING_STARTED, self, "_set_can_interact", [false])
	Signals.Hud.connect(Signals.Hud.CHAT_TYPING_FINISHED, self, "_set_can_interact", [true])
	
	interactor_ray.add_exception(entity)

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

func _unhandled_input(event: InputEvent) -> void:
	if MwInput.is_chat_active or !enabled:
		return
	if entity.owner_peer_id == Network.network_instance.peer_id:
		if (event is InputEventMouseMotion) and (event != null):
			_latest_mouse_motion = event
		if event.is_action_pressed("left_click"):
			_latest_mouse_click = event
	
func _physics_process(delta: float) -> void:
	if entity.owner_peer_id == Network.network_instance.peer_id:
		if !disable_ray_cast and can_interact:
			_try_update_interact()
			_try_request_interact()

# Try to request an interaction.
func _try_request_interact():
	if !_latest_mouse_click:
		return
	
	var result = interactor_ray.get_collider()
	if result is Interactable:
		player_requested_interact(result)
	_latest_mouse_click = null

# Try to update the interaction state & UI display.
func _try_update_interact():
	if !_latest_mouse_motion:
		return
		
	var camera = get_tree().get_root().get_camera()
	var from = camera.project_ray_origin(_latest_mouse_motion.position)
	var to = from + camera.project_ray_normal(
			_latest_mouse_motion.position) * 100
			
	interactor_ray.global_transform.origin = from
	interactor_ray.cast_to = to
	
	var result = interactor_ray.get_collider()
	if result is Interactable:
		_make_hud_display_interactable(result)
	else:
		_make_hud_display_interactable(null)
	
	DebugDraw.c_draw_line(from, to, Color(1,1,0), 1.0)
	
func _make_hud_display_interactable(interactable : Interactable = null) -> void :
	if interactable == null :
		Signals.Hud.emit_signal(Signals.Hud.INTERACTABLE_DISPLAY_HIDDEN)
		Signals.Hud.emit_signal(Signals.Hud.SET_FIRST_PERSON_POSSIBLE_INTERACT, false)
	else :
		Signals.Hud.emit_signal(Signals.Hud.INTERACTABLE_DISPLAY_SHOWN, 
				interactable.title, disable_ray_cast)
		Signals.Hud.emit_signal(Signals.Hud.SET_FIRST_PERSON_POSSIBLE_INTERACT, true)
				
#Called by signal. When false, do not allow the player to press interact. When true, player can interact.
func _set_can_interact(set_can_interact : bool) -> void :
	can_interact = set_can_interact

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
	
	#Let the InteractsDisplay know if I only use InteractsMenu.
	if disable_ray_cast :
		Signals.Hud.emit_signal(Signals.Hud.INTERACTABLE_DISPLAY_SHOWN, 
				"", disable_ray_cast)

#Another interactor has grabbed focus. Perform cleanup.
func lost_focus() -> void :
	has_focus = false
	interactor_ray.disconnect("new_interactable", self, "_make_hud_display_interactable")
	interactor_ray.disconnect("no_interactable_in_reach", self, "_make_hud_display_interactable")

#An Interactable has been chosen from InteractsMenu. Perform the appropriate logic for the Interactable.
func player_requested_interact(interactable : Interactable)->void:
	Log.trace(self, "", "Interacted with %s " %interactable)
	if interactable.is_networked:
		rpc_id(1, "request_interact", [get_path(), interactable.get_path()])
		#I removed entity.owner_peer_id from the now empty array.
	else :
		interactable.interact_with(entity)

#Pass the interactor signals we are listening to onwards.
func relay_signal(attribute = null, signal_name = "interactable_made_impossible") -> void :
	emit_signal(signal_name, attribute)

# This is always run on the server, after a client requests a specific interact.
master func request_interact(args : Array) -> void :
	Log.warning(self, "", "Client %s requested an interaction" %entity.owner_peer_id)
	var interactable = get_node(args[1])
	Log.warning(self, "", "Interact mode: %s" %interactable.network_mode)
	match interactable.network_mode:
		interactable.NetworkMode.CLIENT_SERVER:
			# Run it on the server
			execute_interact(args)
			# If I'm the server, then I already ran my own request in the line above.
			if get_tree().get_rpc_sender_id() != 1:
				rpc_id(get_tree().get_rpc_sender_id(), "execute_interact", args)
		interactable.NetworkMode.CLIENT_ONLY:
			# If server is also a client, just run it locally.
			if get_tree().get_rpc_sender_id() == 1:
				execute_interact(args)
			else:
				rpc_id(get_tree().get_rpc_sender_id(), "execute_interact", args)
		interactable.NetworkMode.SERVER_ONLY:
			# Since this func only runs on the server, we can safely run locally.
			execute_interact(args)
		interactable.NetworkMode.PROPAGATED:
			# Run it once on the server, then propagate it to all clients
			execute_interact(args)
			rpc("execute_interact", args)

puppet func execute_interact(args: Array):
	Log.warning(self, "", "Client %s interacted request executed" %entity.owner_peer_id)
	var interactor = get_node(args[0])
	var interactable = get_node(args[1])
	interactable.interact_with(entity)

func disable():
	#This gets called before _ready.
	if interactor_ray != null :
		interactor_ray.enabled = false
	.disable()

func enable():
	if is_net_owner():
		interactor_ray.enabled = true
	.enable()

