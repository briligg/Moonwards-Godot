extends Spatial

onready var collision = get_parent().get_node("CollisionShape")

var is_docked = false

var docked_to: AEntity

var orig_parent

onready var pod = get_parent()

func _ready():
	$Interactable.owning_entity = self.pod
	$Interactable.display_info = "Dock to rover"
	$Interactable.connect("interacted_by", self, "interacted_by")
	orig_parent = pod.get_parent()

func interacted_by(interactor):
	if interactor.is_in_group("athlete_rover"):
		if !is_docked:
			call_deferred("dock_with", interactor)
		elif is_docked and interactor == docked_to:
			call_deferred("undock")

func dock_with(rover):
	_reparent(pod, rover)
	_reparent(collision, rover)
	pod.transform = rover.get_node("DockPoint").transform
	collision.global_transform = rover.get_node("DockPoint").global_transform
	docked_to = rover
	is_docked = true

func undock():
	_reparent(collision, pod)
	_reparent(pod, orig_parent)
	pod.global_transform = docked_to.get_node("DockPoint").global_transform
	collision.global_transform = pod.global_transform
	docked_to = null
	is_docked = false

func _reparent(node, new_parent):
	var p = node.get_parent()
	p.remove_child(pod)
	new_parent.add_child(node)
	node.owner = new_parent