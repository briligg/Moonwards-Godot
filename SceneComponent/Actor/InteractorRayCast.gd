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


func _new_collider(new_collider : Interactable) -> void :
	if new_collider == null :
		emit_signal("no_interactable_in_reach")
		return
	
	emit_signal("new_interactable", new_collider)

func _physics_process(_delta : float) -> void :
	var camera : Camera = viewport.get_camera()
	rotation.x = -camera.rotation.x

func _ready() -> void :
	connect("collider_changed", self, "_new_collider")

func get_interactable() -> Interactable :
	return previous_collider

#Interact with the given interactable.
func interact(interactable : Interactable) -> void :
	interactable.interact_with(owning_entity)
	emit_signal("interacted_with", interactable)
