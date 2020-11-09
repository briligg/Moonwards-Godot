extends Area
class_name InteractorArea

"""
	Gives a node the ability to interact with interactables.
"""

#This is what I pass as the interactor.
var owning_entity : AEntity

#This is the closest interactable at any given moment.
var closest_interactable : Interactable

var enabled: bool setget set_enabled

#The closest interactable has changed.
signal interactable_entered_area(interactable_node)
signal interactable_left_area(interactable_node)

signal interacted_with(interactable)

#What interactable I am closest to and can interact with.
var interactables : Array = []
#This is how I will not spam a signal when I have potential interacts.
var previous_collider : Area = null

func _ready() -> void:
	collision_layer = 0
	collision_mask = 32768
	enabled = false
	
	connect("area_exited", self, "_interactable_left")
	connect("area_entered", self, "_interactable_entered")

func _interactable_left(interactable_area : Area) -> void :
	emit_signal("interactable_left_area", interactable_area)

func _physics_process(_delta : float) -> void:
	# Set the interactable I am colliding with, that are within distance.
	# This is rather inefficient, optimize when you get the chance.
	interactables = []
	var _interactables = get_overlapping_areas()
	for interactable in _interactables:
		var dist = interactable.global_transform.origin.distance_to(
				self.global_transform.origin)
		if dist > interactable.max_interact_distance:
			interactables.append(interactable)
			
	
#Return what interactables can be interacted with
func get_interactables() -> Array :
	return interactables

#Interact with the given interactable.
func interact(interactable) -> void :
	interactable.interact_with(owning_entity)
	emit_signal("interacted_with", interactable)

#An interactable has entered my area.
func _interactable_entered(interactable_node) -> void :
	emit_signal("interactable_entered_area", interactable_node)

func set_enabled(val: bool) -> void:
	if !val:
		interactables = []
	set_physics_process(val)
	set_process(val)
	set_process_input(val)
	$CollisionShape.disabled = !val
	enabled = val
