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

#How long the Ray cast is.
export var ray_cast_length : float = 50

#Determines if the RayCast Interactor should be active or not.
export var disable_ray_cast : bool = false

var _latest_mouse_motion: InputEventMouseMotion
var _latest_mouse_click: InputEventMouseButton
var _latest_mouse_release: InputEventMouseButton
var _latest_mouse_scroll : InputEventMouseButton
# what we collided with last frame
var _prev_frame_collider
#When chatting, do not interact with objects.
var can_interact : bool = true

#When the mouse is not captured avoid pressing touchscreen with this ray cast.
var touchscreen_clickable : bool = false

var has_focus : bool = false

#This function is required by AComponent.
func _init().("Interactor", true) -> void :
	pass

#Make Interactor have my Entity variable as it's user.
func _ready() -> void :
	#Listen for when chat starts and stops to know when to avoid interacting.
	Signals.Hud.connect(Signals.Hud.CHAT_TYPING_STARTED, self, "_set_can_interact", [false])
	Signals.Hud.connect(Signals.Hud.CHAT_TYPING_FINISHED, self, "_set_can_interact", [true])
	
	Signals.Menus.connect(Signals.Menus.SET_MOUSE_TO_CAPTURED, self, "_mouse_captured")
	
	interactor_ray.add_exception(entity)
	
	#Create a mouse motion because of a bug workaround.
	_latest_mouse_motion = InputEventMouseMotion.new()
	_latest_mouse_motion.relative = Vector2(1,1)

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

#Read input and pass it onto Interactable or Touchscreen.
func _unhandled_input(event: InputEvent) -> void:
	if MwInput.is_chat_active or !enabled:
		return
	if entity.owner_peer_id == Network.network_instance.peer_id:
		
		if (event is InputEventMouseMotion) and (event != null):
			_latest_mouse_motion = event
		
		if event.is_action_pressed("left_click"):
			if event is InputEventMouseButton :
				_latest_mouse_click = event
			else:
				var nw := InputEventMouseButton.new()
				nw.pressed = true
				nw.button_index = BUTTON_LEFT
				_latest_mouse_click = nw
		
		elif event.is_action_released("left_click") :
			if event is InputEventMouseButton :
				_latest_mouse_release = event
			else:
				var nw := InputEventMouseButton.new()
				nw.pressed = false
				nw.button_index = BUTTON_LEFT
				_latest_mouse_release = nw
		
		elif event.is_action("scroll_up") :
			if event.is_action_pressed("scroll_up") :
				var mouse_scroll : InputEventMouseButton = InputEventMouseButton.new()
				mouse_scroll.button_index = BUTTON_WHEEL_UP
				_latest_mouse_scroll = mouse_scroll
			elif event.is_action_released("scroll_up") :
				_latest_mouse_scroll = null
		
		elif event.is_action("scroll_down") :
			if event.is_action_pressed("scroll_down") :
				var mouse_scroll : InputEventMouseButton = InputEventMouseButton.new()
				mouse_scroll.button_index = BUTTON_WHEEL_DOWN
				_latest_mouse_scroll = mouse_scroll
			elif event.is_action_released("scroll_down") :
				_latest_mouse_scroll = null

#This processes stuff for the ray.
func _physics_process(_delta: float) -> void:
	if entity.owner_peer_id == Network.network_instance.peer_id:
		if !disable_ray_cast and can_interact:
			_try_update_interact()
			_try_request_interact()

# Try to update the interaction state & UI display.
func _try_update_interact():
	#We need mouse motion to determine what we are colliding with.
	#Do nothing if mouse motion has not been set.
#	if !_latest_mouse_motion:
#		return
	
	#Get where to cast to and cast to it.
	var camera = get_tree().get_root().get_camera()
	var from = camera.project_ray_origin(_latest_mouse_motion.position)
	var to = from + camera.project_ray_normal(
			_latest_mouse_motion.position) * ray_cast_length
	interactor_ray.global_transform.origin = from
	interactor_ray.cast_to = interactor_ray.to_local(to)
	
	var result = interactor_ray.get_collider()
	
	#Let the previous collider know we left if a new one has replaced it's focus.
	if result != _prev_frame_collider && _prev_frame_collider != null :
		_prev_frame_collider.emit_signal("mouse_exited")
	
	# Call interactable APIs
	if result is Interactable:
		if interactor_ray.global_transform.origin.distance_to(interactor_ray.get_collision_point()) < result.max_interact_distance:
			_make_hud_display_interactable(result)
			result.emit_signal("mouse_entered")
			_prev_frame_collider = result
	
	#If result is an Area it may be a Touchscreen or a Clickable.
	elif result is Area :
		#If we are colliding with a new object, let the old object know.
		if _prev_frame_collider != result :
			result.emit_signal("mouse_entered")
			_prev_frame_collider = result
		
		#Let the new object know if we are scrolling with the scroll wheel.
		if not _latest_mouse_scroll == null :
			result.emit_signal("input_event", camera, _latest_mouse_scroll, interactor_ray.get_collision_point(), interactor_ray.get_collision_normal(), 0)
	
	else:
		if _prev_frame_collider != null:
			_prev_frame_collider = null
		_make_hud_display_interactable(null)

# Try to request an interaction.
func _try_request_interact():
	#If we have released the mouse left click, let the touchscreen know.
	var result = interactor_ray.get_collider()
	if _latest_mouse_release :
		if result is Area && touchscreen_clickable :
			var camera = get_tree().get_root().get_camera()
			result.emit_signal("input_event", camera, _latest_mouse_release, interactor_ray.get_collision_point(), interactor_ray.get_collision_normal(), 0)
		_latest_mouse_release = null
		
		#Do not let anything else know that the mouse has been released.
		return
	
	#Do nothing if the player has not clicked anything.
	if !_latest_mouse_click:
		return
	
	if result is Interactable:
		if interactor_ray.global_transform.origin.distance_to(interactor_ray.get_collision_point()) < result.max_interact_distance:
			player_requested_interact(result)
	
	#If result is an Area listening for mouse event's, let it know we clicked.
	elif result is Area && touchscreen_clickable :
		var camera = get_tree().get_root().get_camera()
		result.emit_signal("input_event", camera, _latest_mouse_click, interactor_ray.get_collision_point(), interactor_ray.get_collision_normal(), 0)
	
	_latest_mouse_click = null


func _make_hud_display_interactable(interactable : Interactable = null) -> void :
	if interactable == null :
		Signals.Hud.emit_signal(Signals.Hud.INTERACTABLE_DISPLAY_HIDDEN)
		Signals.Hud.emit_signal(Signals.Hud.SET_FIRST_PERSON_POSSIBLE_INTERACT, false)
	else :
		Signals.Hud.emit_signal(Signals.Hud.INTERACTABLE_DISPLAY_SHOWN, 
				interactable.display_info, disable_ray_cast)
		Signals.Hud.emit_signal(Signals.Hud.SET_FIRST_PERSON_POSSIBLE_INTERACT, true)

#Called by signal. When false, do not allow the player to press interact. When true, player can interact.
func _set_can_interact(set_can_interact : bool) -> void :
	can_interact = set_can_interact

#Prevent touchscreen double clicks.
func _mouse_captured(mouse_captured : bool) -> void :
	touchscreen_clickable  = mouse_captured

#Return interactable detected by the ray.
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
	
	#Let the InteractsDisplay know if I only use InteractsMenu.
	if disable_ray_cast :
		Signals.Hud.emit_signal(Signals.Hud.INTERACTABLE_DISPLAY_SHOWN, 
				"", disable_ray_cast)

#Another interactor has grabbed focus. Perform cleanup.
func lost_focus() -> void :
	has_focus = false

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
#	var interactor = get_node(args[0])
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

