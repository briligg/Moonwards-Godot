extends Area
class_name Interactor

"""
	Gives a node the ability to interact with interactables.
"""

#This is what I pass as the interactor.
var owning_entity : AEntity

signal interact_made_possible(string_describing_potential_interact)
signal interact_made_impossible()

signal interacted_with(interactable)

#What interactable I am closest to and can interact with.
var interactable : Area = null
#This is how I will not spam a signal when I have potential interacts.
var previous_collider : Area = null

func _ready():
	collision_layer = 0
	collision_mask = 32768

#Determine when I have touched an interactable.
func _physics_process(_delta : float) -> void:
	#Get the interactable I am colliding with.
	var closest_body : Area = null
	var closest_body_distance : float = 99999999999.0
	for body in get_overlapping_areas() :
		var position_from_me : float
		position_from_me = (global_transform.origin - body.global_transform.origin).length()
		#Determine if the new body is closer.
		if position_from_me < closest_body_distance :
			closest_body_distance = position_from_me
			closest_body = body
			interactable = closest_body

	#Exit if I am not touching anything.
	if closest_body == null :
		#If I was colliding with something before but am not now,
		#emit a signal saying that.
		if previous_collider != null :
			emit_signal("interact_made_impossible")
		interactable = null
		previous_collider = null
		return
	
	#Return the interactable's name and notify listener's of it.
	if previous_collider != interactable :
		var interact_info : String = interactable.get_info()
		emit_signal("interact_made_possible", interact_info)
		previous_collider = interactable

#Interact with the closest potential interactable. Can be called when no interactables are present.
func interact() -> void :
	if interactable == null :
		return
	
	interactable.interact_with(owning_entity)
	if interactable.owning_entity != null:
		emit_signal("interacted_with", interactable.owning_entity)
