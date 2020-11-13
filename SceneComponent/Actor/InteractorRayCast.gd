extends MouseSimulatingRayCast
class_name InteractorRayCast


onready var viewport : Viewport = get_tree().root

#A new interactabled is in reach. null if interactable left with no replacement.
signal new_interactable(interactable_interactable)
signal no_interactable_in_reach()

#Emitted when the player interects with the interactable.
signal interacted_with(interactable_interactable)

var available_interactable

#This is what I pass as the interactor.
var owning_entity : AEntity

func _on_new_collider(new_collider) -> void :
	if new_collider is Interactable:
		# Distance to interactable
		var dist = new_collider.global_transform.origin.distance_to(self.global_transform.origin)
		if new_collider.max_interact_distance >= dist:
			emit_signal("new_interactable", new_collider)
			Signals.Hud.emit_signal(Signals.Hud.SET_FIRST_PERSON_POSSIBLE_INTERACT, true)
			available_interactable = new_collider
		else:
			emit_signal("no_interactable_in_reach")
			Signals.Hud.emit_signal(Signals.Hud.SET_FIRST_PERSON_POSSIBLE_INTERACT, false)
			available_interactable = null
			
	elif new_collider == null || not new_collider is Interactable :
		emit_signal("no_interactable_in_reach")
		Signals.Hud.emit_signal(Signals.Hud.SET_FIRST_PERSON_POSSIBLE_INTERACT, false)
		available_interactable = null

func _ready() -> void :
	connect("collided", self, "_on_new_collider")

#Return the interactable I am colliding with. Null if no Interactable is being touched.
func get_interactable() -> Interactable :
	if available_interactable:
		return available_interactable
	else :
		return null

#Interact with the given interactable.
func interact(interactable : Interactable) -> void :
	interactable.interact_with(owning_entity)
	emit_signal("interacted_with", interactable)

#When true is passed, I am processing collisions. False makes me disabled.
func set_activity(is_active : bool) :
	set_collision_mask_bit(0, is_active)
	set_collision_mask_bit(15, is_active)
