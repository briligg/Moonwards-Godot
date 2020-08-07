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

signal title_changed(new_title_string)
signal display_info_changed(new_description_string)

#This is what is displayed when an interactor can interact with me.
export var display_info : String = "Interactable" setget set_display_info
#This string is displayed in the text of the InteractsMenu button.
export var title : String = "Title" setget set_title
#True means that players online can see the interactable be used by others.
export var networked : bool = true
# Whether or not this interactable is available  to receive interactions.
var is_available: bool = true
#Whether or not this interactable has active collision detection.
export var interactions_active : bool = true setget set_active

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

#Turns on or shuts off this interactables collision detection.
func set_active(become_active : bool) -> void :
	if become_active :
		set_collision_layer_bit(15, true)
	else :
		set_collision_layer_bit(15, false)
	
	interactions_active = become_active

func set_display_info(new_display_info : String) -> void :
	display_info = new_display_info
	emit_signal("display_info_changed", display_info)

func set_title(new_title : String) -> void :
	title = new_title
	emit_signal("title_changed", title)
