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
	$Interactable.title = "Undock Passenger Pod"
	_reparent(pod, rover)
	pod.transform = rover.get_node("DockPoint").transform
	docked_to = rover
	is_docked = true

func undock():
	$Interactable.title = "Dock Passenger Pod"
	_reparent(pod, orig_parent)
	pod.global_transform = docked_to.get_node("DockPoint").global_transform
	docked_to = null
	is_docked = false

func _reparent(node, new_parent):
	var p = node.get_parent()
	p.remove_child(node)
	new_parent.add_child(node)
	node.owner = new_parent
