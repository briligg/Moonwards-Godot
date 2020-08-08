extends Spatial

onready var collision = get_parent().get_node("CollisionShape")

const HALF_HEIGHT = 2.23

var is_docked = false

var docked_to: AEntity

var orig_parent

onready var pod = get_parent()

func _ready() -> void:
	$Interactable.owning_entity = self.pod
	$Interactable.display_info = "Dock to rover"
	$Interactable.connect("interacted_by", self, "interacted_by")
	$Interactable.title = "Dock Passenger Pod"
	$Interactable.display_info = ""
	orig_parent = pod.get_parent()

func interacted_by(interactor):
	if interactor.is_in_group("athlete_rover"):
		if !is_docked:
			call_deferred("dock_with", interactor)
		elif is_docked and interactor == docked_to:
			call_deferred("undock")

func dock_with(rover):
	rover.mode = RigidBody.MODE_KINEMATIC
	var rover_anchor = rover.get_node("DockLatch")
	var pod_anchor = get_parent().get_node("DockLatch")
	var original_rover_pos = rover_anchor.global_transform.origin
	
	while(true):
		var dir = (pod_anchor.global_transform.origin - 
				rover_anchor.global_transform.origin).normalized()
#		dir.y = 0
		rover.global_translate(dir * 0.02)
		if pod_anchor.global_transform.origin.distance_to(
					rover_anchor.global_transform.origin) <= .3:
			break
		yield(get_tree(), "physics_frame")
		
	$Interactable.title = "Undock Passenger Pod"
	_reparent(pod, rover)
	var target_xfm = rover.get_node("DockLatch").transform
	pod.transform = target_xfm
	pod.transform.origin.y -= HALF_HEIGHT + .1
	_reparent(collision, rover)
	collision.transform.origin.y = target_xfm.origin.y - HALF_HEIGHT + .1
#	pod.mode = RigidBody.MODE_RIGID
	docked_to = rover
	is_docked = true
	
	var x = 0.0
	var dir = Vector3(0, original_rover_pos.normalized().y, (rover.global_transform.origin.normalized().z))
	while(true):
		rover.global_translate(dir * 0.05)
		x += dir.length() * 0.05
		if x >= 1.5:
			break
		yield(get_tree(), "physics_frame")
	
#	while(true):
#		var dir = (pod_anchor.global_transform.origin - 
#				rover_anchor.global_transform.origin).normalized()
#	#		dir.y = 0
#		rover.global_translate(dir * 0.02)
#		if pod_anchor.global_transform.origin.distance_to(
#					rover_anchor.global_transform.origin) <= .3:
#			break
#		yield(get_tree(), "physics_frame")
	pod.mode = RigidBody.MODE_STATIC
#	rover.add_collision_exception_with(pod)
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

func _align_rover_to_dock(rover):
	pass

func _reparent(node, new_parent):
	var p = node.get_parent()
	p.remove_child(node)
	new_parent.add_child(node)
	node.owner = new_parent
