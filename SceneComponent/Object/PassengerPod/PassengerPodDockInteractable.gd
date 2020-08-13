extends Spatial

onready var collision = get_parent().get_node("CollisionShape")

# The latch that goes into the airlock door
onready var airlock_latch = get_parent().get_node("AirlockLatch")

const HALF_HEIGHT = 2.23

# Is docked to a rover?
var is_docked = false

# The rover it's docked to, if any
var docked_to: AEntity

# Original parent of the pod at spawn
var orig_parent

# The interactable of the door we're docked with or potentially docking with
var _dock_door_interactable

onready var pod = get_parent()

func _ready() -> void:
	$Interactable.owning_entity = self.pod
	$Interactable.display_info = "Dock to rover"
	$Interactable.connect("interacted_by", self, "interacted_by")
	$Interactable.title = "Dock Passenger Pod"
	$Interactable.display_info = ""
	orig_parent = pod.get_parent()
	$AirlockDetector.connect("area_entered", self, "_on_area_entered")
	$AirlockDetector.connect("area_exited", self, "_on_area_exited")
	
func interacted_by(interactor):
	if interactor.is_in_group("athlete_rover"):
		if !is_docked:
			call_deferred("dock_with", interactor)
		elif is_docked and interactor == docked_to:
			if _dock_door_interactable != null:
				call_deferred("undock_to_airlock", interactor)
			else:
				call_deferred("undock")

func dock_with(rover):
	rover.mode = RigidBody.MODE_KINEMATIC
	var rover_anchor = rover.get_node("DockLatch")
	var pod_anchor = get_parent().get_node("DockLatch")
	var original_rover_pos = rover.global_transform.origin
	
	var counter = 0.0
	while(!_lerp_to_coroutine(rover, rover_anchor.global_transform.origin, 
			pod_anchor.global_transform.origin, counter)):
		yield(get_tree(), "physics_frame")
		
	$Interactable.title = "Undock Passenger Pod"
	_reparent(pod, rover)
	var target_xfm = rover.get_node("DockLatch").transform
	pod.transform = target_xfm
	pod.transform.origin.y -= HALF_HEIGHT + .1
	_reparent(collision, rover)
	collision.transform.origin.y = target_xfm.origin.y - HALF_HEIGHT + .1
	docked_to = rover
	is_docked = true
	
	counter = 0.0
	var targz = Vector3(rover.global_transform.origin.x, rover.global_transform.origin.y, original_rover_pos.z)
	while(!_lerp_to_coroutine(rover, rover.global_transform.origin, targz, counter)):
		yield(get_tree(), "physics_frame")

	pod.mode = RigidBody.MODE_STATIC
	rover.mode = RigidBody.MODE_RIGID

func undock():
	$Interactable.title = "Dock Passenger Pod"
	_reparent(pod, orig_parent)
	
	pod.global_transform = docked_to.get_node("DockLatch").global_transform
	pod.global_transform.origin.y -= HALF_HEIGHT + .1
	
	_reparent(collision, pod)
	collision.transform.origin = Vector3.ZERO
	# Offset because the pivot is broken on the pod model
	collision.transform.origin.z = -1
	
	docked_to = null
	is_docked = false
	pod.mode = RigidBody.MODE_RIGID

# Undock from rover and into the airlock
func undock_to_airlock(rover):
	rover.mode = RigidBody.MODE_KINEMATIC
	var original_rover_pos = rover.global_transform.origin
	
	var counter = 0.0
	
	var targxy = Vector3(_dock_door_interactable.global_transform.origin.x, 
			_dock_door_interactable.global_transform.origin.y,
			airlock_latch.global_transform.origin.z)
	while(!_lerp_to_coroutine(rover, airlock_latch.global_transform.origin, targxy, counter)):
		yield(get_tree(), "physics_frame")
	
	counter = 0
	var targz = Vector3(airlock_latch.global_transform.origin.x, 
			airlock_latch.global_transform.origin.y,
			_dock_door_interactable.global_transform.origin.z)
	while(!_lerp_to_coroutine(rover, airlock_latch.global_transform.origin, targz, counter)):
		yield(get_tree(), "physics_frame")
	
	undock()
	pod.mode = RigidBody.MODE_STATIC
	
	var dir = (original_rover_pos - rover.global_transform.origin).normalized()
	while(true):
		rover.global_translate(dir * 0.016)
		if rover.global_transform.origin.distance_to(original_rover_pos) <= 0.05:
			break
		yield(get_tree(), "physics_frame")
		
	rover.mode = RigidBody.MODE_RIGID

# Lerp the rovers' position to a target position
func _lerp_to_coroutine(rover: Node, source: Vector3, target: Vector3, counter: float) -> bool:
	var dir = (target - source).normalized()
	var dist = target.distance_to(source)
	rover.global_translate(dir * 0.016)
	counter += dir.length() * 0.016
	if counter >= dist:
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

func _align_rover_to_dock(rover):
	pass

func _reparent(node, new_parent):
	var p = node.get_parent()
	p.remove_child(node)
	new_parent.add_child(node)
	node.owner = new_parent
