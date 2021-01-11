extends Spatial

#### Some spaghetti code this is! A masterpiece, composed by yours truely.
#### Seriously though, refactor this as soon as you get the chance.
const DOCKABLE_POD_INFO : String = "Dock the passenger pod to the airlock"
const DOCKABLE_POD_TITLE : String = "Dock Passenger Pod"
const DROPPABLE_POD_TITLE : String = "Drop Passenger Pod"
const DROPPABLE_POD_INFO : String = "Drop the passenger pod onto the ground. Get near an airlock to dock the pod instead."
const GRABBABLE_POD_INFO : String = "Pick up the pod with the rover and carry it around."
const GRABBABLE_POD_TITLE : String = "Grab Passenger Pod"

onready var hatch_collision = get_parent().get_node("HatchCollisionShape")
# The latch that goes into the airlock door
onready var airlock_latch = get_parent().get_node("AirlockLatch")

onready var original_path

const HALF_HEIGHT = 1.47

# How far away to move from the dock door, to allow for easier movement
export(float) var dock_door_clearance = 1.5

export(float) var dock_anim_speed = 0.022

##WHAT
export(Array, NodePath) var collision_paths
var collision_shapes: Array


# Is docked to a rover?
var is_docked = false
#True when airlock is in range for docking.
var near_airlock : bool = true
# Are we currently in the process of docking or undocking?
var is_docking = false

# The rover it's docked to, if any
var docked_to: AEntity

# Original parent of the pod at spawn
var orig_parent
# Placeholder that exist in the original parent, for RPCing newly joined players
# when the pod is docked
var placeholder_node

# The interactable of the door we're docked with or potentially docking with
var _dock_door_interactable

onready var pod = get_parent()

func _ready() -> void:
	for path in collision_paths:
		collision_shapes.append(get_node(path))
	
	$Interactable.owning_entity = self.pod
	$Interactable.display_info = GRABBABLE_POD_INFO
	$Interactable.connect("interacted_by", self, "interacted_by")
	$Interactable.connect("sync_for_new_player", self, "sync_for_new_player")
	$Interactable.title = GRABBABLE_POD_TITLE
	orig_parent = pod.get_parent()
	$AirlockDetector.connect("area_entered", self, "_on_area_entered")
	$AirlockDetector.connect("area_exited", self, "_on_area_exited")
	
func interacted_by(interactor):
	if is_docking:
		return
	if interactor.is_in_group("athlete_rover"):
		#Be grabbed by the rover.
		if !is_docked:
			call_deferred("align_and_be_grabbed_by", interactor)
		
		#We are being carried by a rover.
		elif is_docked and interactor == docked_to:
			#We are near an airlock.
			if _dock_door_interactable != null and !_dock_door_interactable.is_docked_to:
				call_deferred("dock_to_airlock", interactor)
			
			else:
				rpc("pup_drop")
				rpc("set_physics_mode", RigidBody.MODE_RIGID)
				call_deferred("drop")
				pod.mode = RigidBody.MODE_RIGID

func generate_placeholder():
	if !is_network_master():
		return
	
	placeholder_node = Spatial.new()
	orig_parent.add_child(placeholder_node)
	placeholder_node.name = get_parent().name
	var placeholder_comp = Spatial.new()
	placeholder_node.add_child(placeholder_comp)
	placeholder_comp.name = self.name

#This is called so the Rover can pick up the pod.
func align_and_be_grabbed_by(rover):
	if _dock_door_interactable:
		_dock_door_interactable.request_close()

	is_docking = true
	rover.mode = RigidBody.MODE_KINEMATIC
	var rover_anchor = rover.get_node("DockLatch")
	var pod_anchor = get_parent().get_node("DockLatch")
	var original_rover_pos = rover.global_transform.origin
	
	while(!_lerp_to_coroutine(rover, rover_anchor.global_transform.origin, 
			pod_anchor.global_transform.origin, dock_anim_speed) and is_docking):
		yield(get_tree(), "physics_frame")
	
	rpc("pup_grab", rover.get_path())
	rpc("set_physics_mode", RigidBody.MODE_STATIC)
	grab(rover)
	pod.mode = RigidBody.MODE_STATIC
	
	# If we're docked to the door or nearby, go backwards a little to give room for movement.
#	if _dock_door_interactable:
	var targz = rover.global_transform.origin - (rover.global_transform.basis.z).normalized() * dock_door_clearance
	while(!_lerp_to_coroutine(rover, rover.global_transform.origin, targz, dock_anim_speed) and is_docking):
		yield(get_tree(), "physics_frame")
	
	rover.mode = RigidBody.MODE_RIGID
	is_docking = false

#This gets called whenever the pod is dropped.
func drop():
	if placeholder_node:
		placeholder_node.queue_free()
	yield(get_tree(), "physics_frame")
	
	$Interactable.title = GRABBABLE_POD_TITLE
	$Interactable.display_info = GRABBABLE_POD_INFO
	_reparent(pod, orig_parent, true)
	
	pod.global_transform = docked_to.get_node("DockLatch").global_transform
	pod.global_transform.origin.y -= HALF_HEIGHT + .1
	
	for col in collision_shapes:
		_reparent(col, pod, true)

	var hxfm = hatch_collision.global_transform
	_reparent(hatch_collision, pod)
	hatch_collision.global_transform = hxfm
	
	docked_to = null
	is_docked = false
	is_docking = false

puppet func pup_drop():
	drop()

#Called when an object is picking up the pod.
func grab(rover_node) -> void :
	if near_airlock :
		$Interactable.title = DOCKABLE_POD_TITLE
		$Interactable.display_info = DOCKABLE_POD_INFO
	else :
		$Interactable.title = DROPPABLE_POD_TITLE
		$Interactable.display_info = DROPPABLE_POD_INFO
	
	_reparent(pod, rover_node)
	var target_xfm = rover_node.get_node("DockLatch").transform
	pod.transform = target_xfm
	pod.transform.origin.y -= HALF_HEIGHT + .1
	for col in collision_shapes:
		_reparent(col, rover_node, true)
	_reparent(hatch_collision, rover_node, true)
	if placeholder_node == null:
		generate_placeholder()
	
	docked_to = rover_node
	is_docked = true

puppet func pup_grab(rover_path) -> void :
	var rover = get_node(rover_path)
	grab(rover)

# Undock from rover and into the airlock
func dock_to_airlock(rover):
	#Do nothing if we are already attempting to dock.
	if is_docking :
		return
	
	is_docking = true
	
	rover.mode = RigidBody.MODE_KINEMATIC
	var dock_point = _dock_door_interactable.dock_point
	
	var targ = Quat(dock_point.global_transform.basis).normalized()
	while(!_slerp_to_coroutine(rover, targ, dock_anim_speed) and is_docking):
		yield(get_tree(), "physics_frame")
#
	# Align XY axes
	var targxy = Vector3(dock_point.global_transform.origin.x, 
			dock_point.global_transform.origin.y,
			airlock_latch.global_transform.origin.z)
	while(!_lerp_to_coroutine(rover, airlock_latch.global_transform.origin, targxy, dock_anim_speed) and is_docking):
		yield(get_tree(), "physics_frame")
		
	# ALign Z axis
	var targz = Vector3(airlock_latch.global_transform.origin.x, 
			airlock_latch.global_transform.origin.y,
			dock_point.global_transform.origin.z)
	while(!_lerp_to_coroutine(rover, airlock_latch.global_transform.origin, targz, dock_anim_speed) and is_docking):
		yield(get_tree(), "physics_frame")
	
	rpc("pup_drop")
	drop()
	# Because drop will reset this.
	is_docking = true
	rpc("set_physics_mode", RigidBody.MODE_STATIC)
	pod.mode = RigidBody.MODE_STATIC
	
	targ = rover.global_transform.origin - (rover.global_transform.basis.z).normalized() * dock_door_clearance
	var dir
	while(is_docking):
		targ = rover.global_transform.origin - (rover.global_transform.basis.z).normalized() * dock_door_clearance
		dir = (targ - rover.global_transform.origin).normalized()
		rover.global_translate(dir * 0.016)
		if rover.global_transform.origin.distance_to(targ) <= 0.05:
			break
		yield(get_tree(), "physics_frame")
		
	if _dock_door_interactable:
		_dock_door_interactable.request_open()
		
	rover.mode = RigidBody.MODE_RIGID
	is_docking = false


func _slerp_to_coroutine(rover: Node, target: Quat, speed:float ) -> bool:
	var b = Quat(rover.global_transform.basis).normalized().slerp(target, speed)
	rover.global_transform.basis = Basis(b)
	if b.dot(target) == 1:
		return true
	return false

# Lerp the rovers' position to a target position
func _lerp_to_coroutine(rover: Node, source: Vector3, target: Vector3, speed: float) -> bool:
	var dir = (target - source).normalized()
	var dist = target.distance_to(source)
	rover.global_translate(dir * speed)
	if speed >= dist:
		return true
	return false

func _on_area_entered(area):
	if area is AirlockDoorInteractable:
		near_airlock = true
		if area.is_dock_door:
			_dock_door_interactable = area
			#Check if the rover has the pod.
			if is_docked :
				$Interactable.display_info = DOCKABLE_POD_INFO
				$Interactable.title = DOCKABLE_POD_TITLE

func _on_area_exited(area):
	yield(get_tree(), "physics_frame")
	if area == _dock_door_interactable:
		if !area.overlaps_area($AirlockDetector):
			near_airlock = false
			$Interactable.title = DROPPABLE_POD_TITLE
			$Interactable.display_info = DROPPABLE_POD_INFO
			_dock_door_interactable = null

func _reparent(node, new_parent, keep_world_pos = false):
	var pos = node.global_transform.origin
	var p = node.get_parent()
	p.remove_child(node)
	new_parent.add_child(node)
	node.owner = new_parent
	if keep_world_pos:
		node.global_transform.origin = pos

puppet func set_physics_mode(mode):
	pod.mode = mode

func sync_for_new_player(peer_id):
	if get_tree().is_network_server():
		var col_transforms = []
		for col in collision_shapes:
			col_transforms.append(col.global_transform)
		if is_docked:
			placeholder_node.get_node(self.name).rpc_id(peer_id, "_dock_for_new_player", docked_to.get_path(), 
					pod.global_transform, col_transforms, 
					hatch_collision.global_transform)
		else:
			rpc("_syncpos_for_new_player", pod.global_transform, 
					col_transforms, 
					hatch_collision.global_transform)

#Attach myself either to an airlock or vehicle for the new player.
puppet func _dock_for_new_player(rover_path, _pod_xfm, col_xfm_arr, col_hatch_xfm):
	$Interactable.title = GRABBABLE_POD_TITLE
	$Interactable.display_info = GRABBABLE_POD_INFO
	var rover = get_node(rover_path)
	_reparent(pod, rover)
	var target_xfm = rover.get_node("DockLatch").transform
	pod.transform = target_xfm
	pod.transform.origin.y -= HALF_HEIGHT + .1
	for i in range(collision_shapes.size()):
		_reparent(collision_shapes[i], rover)
		collision_shapes[i].global_transform = col_xfm_arr[i]
		
	_reparent(hatch_collision, rover)
	hatch_collision.global_transform = col_hatch_xfm
	generate_placeholder()
	docked_to = rover
	is_docked = true

#The pod is just laying on the ground?
puppet func _syncpos_for_new_player(pod_xfm, col_pos_arr, col_hatch_pos):
	pod.global_transform = pod_xfm
	for i in range(collision_shapes.size()):
		collision_shapes[i].global_transform = col_pos_arr[i]
	hatch_collision.global_transform = col_hatch_pos
