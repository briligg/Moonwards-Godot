extends AnimationPlayer

const IDLE_ANIM : String = "Idle"
const INTERACTED_WITH_ANIM : String = "Interacted With"


#Start the idle animation and listen for interactions of my AudioSphere parent.
func _ready() -> void :
	play(IDLE_ANIM)
	
	#Listen for when my parent is interacted_by
	get_parent().connect("interacted_by", self, "_interacted_with")

#Called by a signal. Starts when the player interacted with the AudioSphere.
func _interacted_with(_interactor_ray_cast):
	seek(0)
	play(INTERACTED_WITH_ANIM)
	
	#Listen for when the animation finishes so that I can 
	#start the idle animation again.
	if is_connected("animation_finished", self, "_interacted_with_finished") == false :
		connect("animation_finished", self, "_interacted_with_finished")

#A signal calls this. Interaction animation finished. Go back to idle. 
func _interacted_with_finished(_anim_name : String) -> void :
	#Stop listening for the animations to finish
	disconnect("animation_finished", self, "_interacted_with_finished")
	
	seek(0)
	play(IDLE_ANIM)
