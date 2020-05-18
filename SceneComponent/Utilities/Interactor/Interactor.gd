extends Area

"""
	Gives a node the ability to interact with interactables.
"""

#This is what I pass as the interactor.
export var user : NodePath = get_path()

signal interact_possible(string_describing_potential_interact)
signal interact_became_impossible()

#What interactable I am closest to and can interact with.
var collider : Area = null
#This is how I will not spam a signal when I have potential interacts.
var previous_collider : Area = null


#warning-ignore:unused_argument
#Determine when I have touched an interactable.
func _physics_process(delta : float) -> void:
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
			collider = closest_body

	#Exit if I am not touching anything.
	if closest_body == null :
		#If I was colliding with something before but am not now,
		#emit a signal saying that.
		if previous_collider != null :
			emit_signal("interact_became_impossible")
		collider = null
		previous_collider = null
		return
	
	#Return the interactable's name and notify listener's of it.
	if previous_collider != collider :
		var interact_info : String = collider.get_info()
		emit_signal("interact_possible", interact_info)
		previous_collider = collider

#Interact with the closest potential interactable. Can be called when no interactables are present.
func interact() -> void :
	if collider == null :
		return
	
	collider.interact_with(user)


