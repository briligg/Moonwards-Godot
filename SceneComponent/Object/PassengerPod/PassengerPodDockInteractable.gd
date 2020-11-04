extends Spatial

onready var hatch_collision = get_parent().get_node("HatchCollisionShape")
# The latch that goes into the airlock door
onready var airlock_latch = get_parent().get_node("AirlockLatch")

onready var original_path

const HALF_HEIGHT = 1.47

# How far away to move from the dock door, to allow for easier movement
export(float) var dock_door_clearance = 1.5

export(float) var dock_anim_speed = 0.022

export(Array, NodePath) var collision_paths
var collision_shapes: Array


# Is docked to a rover?
var is_docked = false
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
	$Interactable.display_info = "Dock to rover"
	$Interactable.connect("interacted_by", self, "interacted_by")
	$Interactable.connect("sync_for_new_player", self, "sync_for_new_player")
	$Interactable.title = "Dock Passenger Pod"
	$Interactable.display_info = ""
	orig_parent = pod.get_parent()
	$AirlockDetector.connect("area_entered", self, "_on_area_entered")
	$AirlockDetector.connect("area_exited", self, "_on_area_exited")
	
func interacted_by(interactor):
	if is_docking:
		return
	if interactor.is_in_group("athlete_rover"):
		if !is_docked:
			call_deferred("align_and_dock_with", interactor)
		elif is_docked and interactor == docked_to:
			if _dock_door_interactable != null:
				call_deferred("undock_to_airlock", interactor)
			else:
				rpc("pup_undock")
				rpc("set_physics_mode", RigidBody.MODE_RIGID)
				call_deferred("undock")
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

func align_and_dock_with(rover):
	is_docking = true
	rover.mode = RigidBody.MODE_KINEMATIC
	var rover_anchor = rover.get_node("DockLatch")
	var pod_anchor = get_parent().get_node("DockLatch")
	var original_rover_pos = rover.global_transform.origin
	
	while(!_lerp_to_coroutine(rover, rover_anchor.global_transform.origin, 
			pod_anchor.global_transform.origin, dock_anim_speed) and is_docking):
		yield(get_tree(), "physics_frame")
	
	rpc("pup_dock_with", rover.get_path())
	rpc("set_physics_mode", RigidBody.MODE_STATIC)
	dock_with(rover)
	pod.mode = RigidBody.MODE_STATIC
	
	# If we're docked to the door or nearby, go backwards a little to give room for movement.
#	if _dock_door_interactable:
	var targz = rover.global_transform.origin - (rover.global_transform.basis.z).normalized() * dock_door_clearance
	while(!_lerp_to_coroutine(rover, rover.global_transform.origin, targz, dock_anim_speed) and is_docking):
		yield(get_tree(), "physics_frame")

	rover.mode = RigidBody.MODE_RIGID
	is_docking = false
	
func dock_with(rover):
	$Interactable.title = "Undock Passenger Pod"
	_reparent(pod, rover)
	var target_xfm = rover.get_node("DockLatch").transform
	pod.transform = target_xfm
	pod.transform.origin.y -= HALF_HEIGHT + .1
	for col in collision_shapes:
		_reparent(col, rover, true)
	_reparent(hatch_collision, rover, true)
	if placeholder_node == null:
		generate_placeholder()
	
	docked_to = rover
	is_docked = true
	
puppet func pup_dock_with(rover_path):
	var rover = get_node(rover_path)
	dock_with(rover)

func undock():
	is_docking = true
	if placeholder_node:
		placeholder_node.queue_free()
	yield(get_tree(), "physics_frame")
	
	$Interactable.title = "Dock Passenger Pod"
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

puppet func pup_undock():
	undock()

# Undock from rover and into the airlock
func undock_to_airlock(rover):
	is_docking = true
	rover.mode = RigidBody.MODE_KINEMATIC
	var original_rover_pos = rover.global_transform.origin
	
	var targ = Quat(_dock_door_interactable.global_transform.basis).normalized()
	while(!_slerp_to_coroutine(rover, targ, dock_anim_speed) and is_docking):
		yield(get_tree(), "physics_frame")
#
	# Align XY axes
	var targxy = Vector3(_dock_door_interactable.global_transform.origin.x, 
			_dock_door_interactable.global_transform.origin.y,
			airlock_latch.global_transform.origin.z)
	while(!_lerp_to_coroutine(rover, airlock_latch.global_transform.origin, targxy, dock_anim_speed) and is_docking):
		yield(get_tree(), "physics_frame")
		
	# ALign Z axis
	var targz = Vector3(airlock_latch.global_transform.origin.x, 
			airlock_latch.global_transform.origin.y,
			_dock_door_interactable.global_transform.origin.z)
	while(!_lerp_to_coroutine(rover, airlock_latch.global_transform.origin, targz, dock_anim_speed) and is_docking):
		yield(get_tree(), "physics_frame")
	
	rpc("pup_undock")
	undock()
	# Because undock will reset this.
	is_docking = true
	rpc("set_physics_mode", RigidBody.MODE_STATIC)
	pod.mode = RigidBody.MODE_STATIC
	
	targ = rover.global_transform.origin - (rover.global_transform.basis.z).normalized() * dock_door_clearance
	var dir = (targ - rover.global_transform.origin).normalized()
	while(is_docking):
		rover.global_translate(dir * 0.016)
		if rover.global_transform.origin.distance_to(targ) <= 0.05:
			break
		yield(get_tree(), "physics_frame")
		
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
		if area.is_dock_door:
			_dock_door_interactable = area
			$Interactable.display_info = "Undock Passenger Pod from the rover and into the airlock door"

func _on_area_exited(area):
	yield(get_tree(), "physics_frame")
	if area == _dock_door_interactable:
		if !area.overlaps_area($AirlockDetector):
			$Interactable.display_info = ""
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
		var col_positions = []
		for col in collision_shapes:
			col_positions.append(col.global_transform.origin)
		if is_docked:
			placeholder_node.get_node(self.name).rpc_id(peer_id, "_dock_for_new_player", docked_to.get_path(), 
					pod.global_transform.origin, col_positions, 
					hatch_collision.global_transform.origin)
		else:
			rpc("_syncpos_for_new_player", pod.global_transform.origin, 
					col_positions, 
					hatch_collision.global_transform.origin)

puppet func _dock_for_new_player(rover_path, pod_pos, col_pos_arr, col_hatch_pos):
	$Interactable.title = "Undock Passenger Pod"
	var rover = get_node(rover_path)
	_reparent(pod, rover)
	var target_xfm = rover.get_node("DockLatch").transform
	pod.transform = target_xfm
	pod.transform.origin.y -= HALF_HEIGHT + .1
	for i in range(collision_shapes.size()):
		_reparent(collision_shapes[i], rover)
		collision_shapes[i].global_transform.origin = col_pos_arr[i]
		
	_reparent(hatch_collision, rover)
	hatch_collision.global_transform.origin = col_hatch_pos
	generate_placeholder()
	docked_to = rover
	is_docked = true

puppet func _syncpos_for_new_player(pod_pos, col_pos_arr, col_hatch_pos):
	pod.global_transform.origin = pod_pos
	for i in range(collision_shapes.size()):
		collision_shapes[i].global_transform.origin = col_pos_arr[i]
	hatch_collision.global_transform.origin = col_hatch_pos
