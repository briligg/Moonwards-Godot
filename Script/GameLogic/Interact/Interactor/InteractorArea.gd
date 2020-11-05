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
signal closest_interactable_changed(interactable)
signal interactable_entered_area(interactable_node)
signal interactable_left_area(interactable_node)
signal interact_made_possible(string_closest_potential_interact)
signal interact_made_impossible()

signal interacted_with(interactable)

#What interactable I am closest to and can interact with.
var interactables : Array = []
#This is how I will not spam a signal when I have potential interacts.
var previous_collider : Area = null

func _ready() -> void:
	collision_layer = 0
	collision_mask = 32768
	enabled = false
	
	connect("area_entered", self, "_interactable_entered")
	connect("area_exited", self, "_interactable_exited")

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
			emit_signal("closest_interactable_changed", null)
		interactables = []
		previous_collider = null
		closest_interactable = null
		return
	
	#Return the interactable's name and notify listener's of it.
	if previous_collider != closest_body :
		var interact_info : String = closest_body.get_info()
		emit_signal("interact_made_possible", interact_info)
		emit_signal("closest_interactable_changed", closest_body)
		previous_collider = closest_body
		closest_interactable = closest_body

#Returns null if there is no Interactable.
func get_closest_interactable() -> Interactable :
	return closest_interactable

#Return what interactables can be interacted with
func get_interactables() -> Array :
	return interactables

#Interact with the given interactable.
func interact(interactable) -> void :
	interactable.interact_with(owning_entity)
	emit_signal("interacted_with", interactable)

#Called from the Interactable when it has left.
func interactable_left(interactable : Interactable) -> void :
	emit_signal("interactable_left_area", interactable)

#Called from the Interactable when interaction is possible.
func new_interactable(interactable : Interactable) -> void :
	emit_signal("interactable_entered_area", interactable)

#An interactable has entered my area.
func _interactable_entered(interactable_node : Interactable) -> void :
	interactable_node.new_possible_interactor(self)

#Interactable left my area.
func _interactable_exited(interactable : Interactable) -> void :
	interactable.interactor_left(self)

func set_enabled(val: bool) -> void:
	if !val:
		interactables = []
	set_physics_process(val)
	set_process(val)
	set_process_input(val)
	$CollisionShape.disabled = !val
	enabled = val
