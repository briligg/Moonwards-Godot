extends Area

"""
 For interacting with the player. 
 Use inside the body that you would like it
 to connect to. 
 I emit interacted_with when an interactor interacts with me. 
	Passes the node that requested the interact in the signal.

"""

#This is what is displayed when an interactor can interact with me.
export var display_info : String = "Interactable"


signal interacted_with( interactor_ray_cast )


func get_info() -> String :
	#Show what the display info should be for interacting with me.
	return display_info


func interact_with( interactor : Node ) -> void :
	#Someone requested interaction with me.
	emit_signal( "interacted_with", interactor )
