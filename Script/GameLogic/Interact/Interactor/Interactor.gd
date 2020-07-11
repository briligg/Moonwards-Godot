extends Area
class_name Interactor

"""
	Gives a node the ability to interact with interactables.
"""

#This is what I pass as the interactor.
var owning_entity : AEntity

var enabled: bool setget set_enabled

signal interactable_entered_area(interactable_node)
signal interactable_left_area(interactable_node)
signal interact_made_possible(string_closest_potential_interact)
signal interact_made_impossible()

signal interacted_with(interactable)

#What interactable I am closest to and can interact with.
var interactables : Array = []
#This is how I will not spam a signal when I have potential interacts.
var previous_collider : Area = null

func _ready():
	collision_layer = 0
	collision_mask = 32768
	enabled = false
	
	connect("area_exited", self, "_interactable_left")
	connect("area_entered", self, "_interactable_entered")

func _interactable_left(interactable_area : Area) -> void :
	emit_signal("interactable_left_area", interactable_area)

#Determine what Interactables I am touching.
func _physics_process(_delta : float) -> void:
	#Get the interactable I am colliding with.
	var closest_body : Area = null
	var closest_body_distance : float = 99999999999.0
	interactables = get_overlapping_areas()
	for body in interactables :
		var position_from_me : float
		position_from_me = (global_transform.origin - body.global_transform.origin).length()
		#Determine if the new body is closer.
		if position_from_me < closest_body_distance :
			closest_body_distance = position_from_me
			closest_body = body

	#Exit if I am not touching anything.
	if closest_body == null :
		#If I was colliding with something before but am not now,
		#emit a signal saying that.
		if previous_collider != null :
			emit_signal("interact_made_impossible")
		interactables = []
		previous_collider = null
		return
	
	#Return the interactable's name and notify listener's of it.
	if previous_collider != closest_body :
		var interact_info : String = closest_body.get_info()
		emit_signal("interact_made_possible", interact_info)
		previous_collider = closest_body

#Return what interactables can be interacted with
func get_potential_interacts() -> Array :
	return interactables

#Interact with the given interactable.
func interact(interactable) -> void :
	assert(interactables.empty() == false)
	interactable.interact_with(owning_entity)
	emit_signal("interacted_with", interactable.owning_entity)

#Interact with the closest potential interactable. Can be called when no interactables are present.
func interact_with_closest() -> void :
	if interactables.empty() :
		return
	
	interactables[0].interact_with(owning_entity)
	if interactables[0].owning_entity != null:
		emit_signal("interacted_with", interactables[0].owning_entity)

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
