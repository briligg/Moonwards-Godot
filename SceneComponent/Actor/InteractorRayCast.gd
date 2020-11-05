extends MouseSimulatingRayCast
class_name InteractorRayCast


onready var viewport : Viewport = get_tree().root

#A new interactabled is in reach. null if interactable left with no replacement.
signal new_interactable(interactable_interactable)
signal no_interactable_in_reach()

#Emitted when the player interects with the interactable.
signal interacted_with(interactable_interactable)


#This is what I pass as the interactor.
var owning_entity : AEntity

#The valid interactable we can interact with
var valid_interactable : Interactable

#The interactable we were previously colliding with.
var previous_interactable : Interactable


func _new_collider(new_collider) -> void :
	if new_collider == null :
		if not previous_interactable == null :
			emit_signal("no_interactable_in_reach")
			previous_interactable.interactor_left(self)
			previous_interactable = null
			valid_interactable = null
		return
	elif not new_collider is Interactable :
		if not previous_interactable == null :
			Signals.Hud.emit_signal(Signals.Hud.SET_FIRST_PERSON_POSSIBLE_INTERACT, false)
			emit_signal("no_interactable_in_reach")
			previous_interactable.interactor_left(self)
			previous_interactable = null
			valid_interactable = null

		return
	
	new_collider.new_possible_interactor(self)
	previous_interactable = new_collider

func _physics_process(_delta : float) -> void :
	var camera : Camera = viewport.get_camera()
	self.global_transform.basis.x = -camera.global_transform.basis.x
	self.global_transform.basis.z = -camera.global_transform.basis.z

func _ready() -> void :
	connect("collider_changed", self, "_new_collider")

#Return the interactable I am colliding with. Null if no Interactable is being touched.
func get_interactable() -> Interactable :
	if not valid_interactable == null :
		return valid_interactable
	else :
		return null

#Interact with the given interactable.
func interact(interactable : Interactable) -> void :
	interactable.interact_with(owning_entity)
	emit_signal("interacted_with", interactable)

#Called from the Interactable when it has left.
func interactable_left(_interactable : Interactable) -> void :
	valid_interactable = null
	Signals.Hud.emit_signal(Signals.Hud.SET_FIRST_PERSON_POSSIBLE_INTERACT, false)
	emit_signal("no_interactable_in_reach")

#Called from the Interactable when interaction is possible.
func new_interactable(interactable : Interactable) -> void :
	valid_interactable = interactable
	
	emit_signal("new_interactable", interactable)
	
	Signals.Hud.emit_signal(Signals.Hud.SET_FIRST_PERSON_POSSIBLE_INTERACT, true)

#When true is passed, I am processing collisions. False makes me disabled.
func set_activity(is_active : bool) :
	set_collision_mask_bit(0, is_active)
	set_collision_mask_bit(15, is_active)
