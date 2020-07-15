extends Area
class_name Interactable
"""
 For interacting with the player. 
 Use inside the body that you would like it
 to connect to. 
 I emit interacted_with when an interactor interacts with me. 
	Passes the node that requested the interact in the signal.
"""

signal interacted_by(interactor_ray_cast)

#This is what is displayed when an interactor can interact with me.
export var display_info : String = "Interactable"
#This string is displayed in the text of the InteractsMenu button.
export var title : String = "Title"
#True means that players online can see the interactable be used by others.
export var networked : bool = true

var owning_entity: AEntity = null

func _ready() -> void :
	collision_layer = 32768
	collision_mask = 0

func get_info() -> String :
	#Show what the display info should be for interacting with me.
	return display_info

func get_title() -> String :
	return title

func interact_with(interactor : Node) -> void :
	#Someone requested interaction with me.
	emit_signal("interacted_by", interactor)

func is_networked() -> bool :
	return networked

func set_title(new_title : String) -> void :
	title = new_title
